#!/usr/bin/env bash
set -euo pipefail

# Migrates the existing CloudFront distribution origin from an old S3 bucket (e.g. us-west-2)
# to a new S3 bucket in us-east-1, syncing content and updating bucket policy.
#
# Requires: aws CLI authenticated + jq installed.

# ====== CONFIG (edit if needed) ======
AWS_REGION="us-east-1"
OLD_BUCKET="bstri-site-20260111033240927600000001"
DIST_ID="E2AQXKDHU0QFRE"
NEW_BUCKET_PREFIX="bstri-site-use1" # bucket name must be globally unique
# =====================================

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
echo "Account: $ACCOUNT_ID"
echo "Old bucket: $OLD_BUCKET"
echo "CloudFront dist: $DIST_ID"

# Get distribution config + ETag
ETAG="$(aws cloudfront get-distribution-config --id "$DIST_ID" --query ETag --output text)"
aws cloudfront get-distribution-config --id "$DIST_ID" --output json > /tmp/cf-dist.json

# Discover current origin (assumes single origin or first origin is the S3 origin)
OLD_ORIGIN_DOMAIN="$(jq -r '.DistributionConfig.Origins.Items[0].DomainName' /tmp/cf-dist.json)"
OAC_ID="$(jq -r '.DistributionConfig.Origins.Items[0].OriginAccessControlId // empty' /tmp/cf-dist.json)"
DIST_ARN="arn:aws:cloudfront::${ACCOUNT_ID}:distribution/${DIST_ID}"

echo "Old origin domain: $OLD_ORIGIN_DOMAIN"
echo "OAC ID: ${OAC_ID:-<none>}"
echo "Dist ARN: $DIST_ARN"

if [[ -z "${OAC_ID:-}" ]]; then
  echo "ERROR: No OriginAccessControlId found on the distribution origin; aborting."
  exit 1
fi

# Create a globally-unique bucket name
SUFFIX="$(date +%Y%m%d%H%M%S)"
NEW_BUCKET="${NEW_BUCKET_PREFIX}-${SUFFIX}"
echo "New bucket: $NEW_BUCKET (region $AWS_REGION)"

# 1) Create new bucket in us-east-1
aws s3api create-bucket --bucket "$NEW_BUCKET" --region "$AWS_REGION" >/dev/null
aws s3api put-public-access-block --bucket "$NEW_BUCKET" --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true >/dev/null

# (Optional but recommended) Enable versioning + SSE
aws s3api put-bucket-versioning --bucket "$NEW_BUCKET" --versioning-configuration Status=Enabled >/dev/null
aws s3api put-bucket-encryption --bucket "$NEW_BUCKET" --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' >/dev/null

# 2) Sync content old -> new
aws s3 sync "s3://${OLD_BUCKET}" "s3://${NEW_BUCKET}" --delete

# 3) Apply bucket policy allowing CloudFront to read
cat > /tmp/new-bucket-policy.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCloudFrontServiceRead",
      "Effect": "Allow",
      "Principal": { "Service": "cloudfront.amazonaws.com" },
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::${NEW_BUCKET}/*"],
      "Condition": {
        "StringEquals": { "AWS:SourceArn": "${DIST_ARN}" }
      }
    }
  ]
}
JSON
aws s3api put-bucket-policy --bucket "$NEW_BUCKET" --policy file:///tmp/new-bucket-policy.json

# 4) Update CloudFront origin domain to point to the NEW bucket regional domain
NEW_ORIGIN_DOMAIN="${NEW_BUCKET}.s3.${AWS_REGION}.amazonaws.com"
echo "New origin domain: $NEW_ORIGIN_DOMAIN"

jq --arg dom "$NEW_ORIGIN_DOMAIN" '
  .DistributionConfig
  | .Origins.Items[0].DomainName = $dom
' /tmp/cf-dist.json > /tmp/cf-dist-updated-config.json

aws cloudfront update-distribution \
  --id "$DIST_ID" \
  --if-match "$ETAG" \
  --distribution-config file:///tmp/cf-dist-updated-config.json >/dev/null

echo "Waiting for distribution to deploy..."
aws cloudfront wait distribution-deployed --id "$DIST_ID"

# 5) Invalidate to be safe
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths '/*' >/dev/null

echo
echo "CUTOVER COMPLETE"
echo "New bucket: $NEW_BUCKET"
echo "Next: update GitHub repo variable S3_BUCKET to $NEW_BUCKET and redeploy."
echo "Cleanup later: aws s3 rb s3://$OLD_BUCKET --force (ONLY after you confirm site works)"
