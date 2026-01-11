variable "project_name" {
  type        = string
  description = "Prefix used for naming AWS resources"
  default     = "bstri"
}

variable "site_bucket_name" {
  type        = string
  description = "If set, use/import an existing site bucket name instead of creating a new one."
  default     = null
}

variable "aws_region" {
  type        = string
  description = "Region for regional resources (S3, etc.)"
  default     = "us-east-1"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository in owner/repo form used to scope OIDC (e.g. lenhofr/bstri)"
  default     = "lenhofr/bstri"
}

variable "existing_oidc_provider_arn" {
  type        = string
  description = "Reuse an existing GitHub Actions OIDC provider instead of creating one (accepts ARN or host like token.actions.githubusercontent.com)."
  default     = "token.actions.githubusercontent.com"
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
  description = "Optional Route53 hosted zone ID used for ACM DNS validation + alias record."
  default     = null
}

variable "create_route53_record" {
  type        = bool
  description = "When true, create Route53 alias record for custom_domain_name in route53_zone_id."
  default     = false
}
