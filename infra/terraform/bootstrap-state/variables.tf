variable "region" {
  type    = string
  default = "us-west-2"
}

variable "project" {
  type    = string
  default = "bstri"
}

variable "state_bucket_name" {
  type        = string
  description = "Optional fixed S3 bucket name to use for Terraform state (preferred for stable CI config)."
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
