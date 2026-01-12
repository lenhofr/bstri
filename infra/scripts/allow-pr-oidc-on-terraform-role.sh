#!/usr/bin/env bash
set -euo pipefail

# Allows GitHub Actions OIDC to assume the Terraform role for both:
# - main branch applies, and
# - pull_request event (for PR terraform plan)
#
# Requires: aws CLI authenticated with iam:UpdateAssumeRolePolicy.

ROLE_NAME="${ROLE_NAME:-bstri-github-actions-terraform}"
GITHUB_OWNER="${GITHUB_OWNER:-lenhofr}"
GITHUB_REPO="${GITHUB_REPO:-bstri}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"

cat > /tmp/bstri-terraform-trust.json <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Federated": "${PROVIDER_ARN}" },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": [
            "repo:${GITHUB_OWNER}/${GITHUB_REPO}:ref:refs/heads/main",
            "repo:${GITHUB_OWNER}/${GITHUB_REPO}:pull_request"
          ]
        }
      }
    }
  ]
}
JSON

echo "Updating trust policy for role: ${ROLE_NAME}"
aws iam update-assume-role-policy --role-name "${ROLE_NAME}" --policy-document file:///tmp/bstri-terraform-trust.json

echo "Updated. Current Condition:"
aws iam get-role --role-name "${ROLE_NAME}" --query 'Role.AssumeRolePolicyDocument.Statement[0].Condition' --output json

rm -f /tmp/bstri-terraform-trust.json
