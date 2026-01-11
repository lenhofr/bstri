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
