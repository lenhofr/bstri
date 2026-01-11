# Terraform: static site (draft)

Goal: deploy the static build output (Next.js export) to **S3 + CloudFront** without changing your current Route53 apex records until you’re ready.

## Outputs
- CloudFront distribution domain name (use this for initial testing)

## Later
- Optional Route53 records for `staging.barsportstri.com` and/or apex cutover.
