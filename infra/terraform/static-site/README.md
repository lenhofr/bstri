# Terraform: static site (draft)

Goal: deploy the static build output (Next.js export) to **S3 + CloudFront** without changing your current Route53 apex records until you’re ready.

## Two ways to test
1) **CloudFront domain only** (no Route53 changes)
- Leave `custom_domain_name = null`

2) **Custom domain (recommended for dev/staging)**
- Set `custom_domain_name` (e.g. `staging.barsportstri.com` or `staging.barsportsdev.com`)
- Set `route53_zone_id` (e.g. `Z01690676SKXJJ64Z6DA`)
- Set `create_route53_record = true` to create the alias record

This will create **only** the requested record + ACM DNS validation records in that hosted zone (it will not touch your barsportstri.com apex unless you choose it).

## Outputs
- CloudFront distribution domain name (always)
- S3 bucket name
