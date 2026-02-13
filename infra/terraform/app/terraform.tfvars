# Production environment (do not point at dev resources)
#
# NOTE: We intentionally leave custom_domain_name unset until cutover because
# CloudFront aliases must be unique, and barsportstri.com is currently attached
# to an existing CloudFront distribution fronting Azure.
aws_region             = "us-east-1"
project_name           = "bstri-prod"
site_bucket_name       = null
custom_domain_name     = null
alternate_domain_names = []
redirect_www_to_apex   = false
route53_zone_id        = "Z060600126TCGHWM3E17Y" # barsportstri.com hosted zone
create_route53_record  = false
