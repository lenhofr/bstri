variable "region" {
  type        = string
  description = "AWS region for S3 and most resources"
  default     = "us-west-2"
}

variable "project" {
  type        = string
  description = "Name prefix for resources"
  default     = "bstri"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "custom_domain_name" {
  type        = string
  description = "Optional custom domain (e.g. staging.barsportstri.com). Leave null to use CloudFront domain."
  default     = null
}

variable "route53_zone_id" {
  type        = string
  description = "Optional Route53 hosted zone ID used for ACM DNS validation + alias record. Example: Z01690676SKXJJ64Z6DA"
  default     = null
}

variable "create_route53_record" {
  type        = bool
  description = "When true, create Route53 alias record for custom_domain_name in route53_zone_id."
  default     = false
}
