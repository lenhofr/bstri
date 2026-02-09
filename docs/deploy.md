# Deploy (GitHub Actions)

We deploy the **static Next.js build** (`web/out`) to S3 and then invalidate CloudFront.

## Required GitHub configuration

### Repo secrets
- `AWS_TERRAFORM_ROLE_ARN` — IAM role to assume via GitHub OIDC for Terraform apply/outputs (deploy role ARN is read from Terraform outputs at deploy-time)

### Repo variables
This repo reads these from Terraform outputs at deploy-time, so you generally don’t need repo variables for bucket/distribution IDs.

## IAM permissions (minimum)
The role assumed by GitHub Actions needs permissions similar to:
- `s3:ListBucket` on the bucket
- `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` on `bucket/*`
- `cloudfront:CreateInvalidation` on the distribution

## Notes
- This workflow does **not** run Terraform; infra is applied separately.
- Preferred Terraform stack is now `infra/terraform/app` (single-state jf-com style). Legacy stacks remain for now during migration.
- Apex cutover for `barsportstri.com` should be done only when ready.
