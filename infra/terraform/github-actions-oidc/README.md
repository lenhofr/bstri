# Terraform: GitHub Actions OIDC role

Creates:
- `token.actions.githubusercontent.com` OIDC provider (if not already present)
- IAM role assumable by GitHub Actions for this repo/branch
- Least-privilege policy for `aws s3 sync` + CloudFront invalidation

## Apply
```bash
cd infra/terraform/github-actions-oidc
terraform init
terraform apply \
  -var github_owner=lenhofr \
  -var github_repo=bstri \
  -var github_branch=main \
  -var s3_bucket_name=<from static-site output bucket_name> \
  -var cloudfront_distribution_id=<from static-site output cloudfront_distribution_id>
```

## Output
- `role_arn` → set this as GitHub secret `AWS_ROLE_ARN`
