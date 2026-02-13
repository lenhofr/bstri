# Production environment (do not point at dev resources)
#
# NOTE: We intentionally leave custom_domain_name unset until cutover because
# CloudFront aliases must be unique, and barsportstri.com is currently attached
# to an existing CloudFront distribution fronting Azure.
aws_region             = "us-east-1"
project_name           = "bstri-prod"
site_bucket_name       = null

# Cutover: attach barsportstri.com + www to the NEW CloudFront distribution.
custom_domain_name        = "barsportstri.com"
alternate_domain_names    = ["www.barsportstri.com"]
redirect_www_to_apex      = true
existing_acm_certificate_arn = "arn:aws:acm:us-east-1:217354297026:certificate/6fa136fd-7274-4965-b7f4-d1a9714fe9a7"

route53_zone_id        = "Z060600126TCGHWM3E17Y" # barsportstri.com hosted zone
create_route53_record  = true
