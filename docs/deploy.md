# Deploy (GitHub Actions)

We deploy the **static Next.js build** (`web/out`) to S3 and then invalidate CloudFront.

## Required GitHub configuration

### Repo secret
- `AWS_ROLE_ARN` — IAM role to assume via GitHub OIDC

### Repo variables
- `AWS_REGION` — region where the S3 bucket exists (e.g. `us-west-2`)
- `S3_BUCKET` — bucket name created by Terraform output `bucket_name`
- `CLOUDFRONT_DISTRIBUTION_ID` — CloudFront distribution id

## IAM permissions (minimum)
The role assumed by GitHub Actions needs permissions similar to:
- `s3:ListBucket` on the bucket
- `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` on `bucket/*`
- `cloudfront:CreateInvalidation` on the distribution

## Notes
- This workflow does **not** run Terraform; infra is applied separately.
- Apex cutover for `barsportstri.com` should be done only when ready.
