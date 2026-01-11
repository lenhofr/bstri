variable "region" {
  type        = string
  description = "Provider region (IAM is global, but AWS provider requires a region)"
  default     = "us-west-2"
}

variable "project" {
  type        = string
  description = "Name prefix"
  default     = "bstri"
}

variable "github_owner" {
  type        = string
  description = "GitHub org/user, e.g. lenhofr"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name, e.g. bstri"
}

variable "github_branch" {
  type        = string
  description = "Branch allowed to deploy, e.g. main"
  default     = "main"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name (Terraform static-site output bucket_name)"
}

variable "cloudfront_distribution_id" {
  type        = string
  description = "CloudFront distribution id (Terraform static-site output cloudfront_distribution_id)"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "create_terraform_role" {
  type        = bool
  description = "Create a separate role for Terraform apply from GitHub Actions"
  default     = true
}

variable "terraform_role_policy_arn" {
  type        = string
  description = "Policy to attach to the Terraform role. For dev, AdministratorAccess is simplest; tighten later."
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
