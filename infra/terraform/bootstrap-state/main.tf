locals {
  tags = merge(var.tags, { project = var.project })
}

resource "aws_s3_bucket" "tf_state_named" {
  count  = var.state_bucket_name != null ? 1 : 0
  bucket = var.state_bucket_name
  tags   = local.tags
}

resource "aws_s3_bucket" "tf_state" {
  count         = var.state_bucket_name == null ? 1 : 0
  bucket_prefix = "${var.project}-tfstate-"
  tags          = local.tags
}

locals {
  tf_state_bucket_id   = var.state_bucket_name != null ? aws_s3_bucket.tf_state_named[0].id : aws_s3_bucket.tf_state[0].id
  tf_state_bucket_name = var.state_bucket_name != null ? aws_s3_bucket.tf_state_named[0].bucket : aws_s3_bucket.tf_state[0].bucket
  tf_state_bucket_arn  = var.state_bucket_name != null ? aws_s3_bucket.tf_state_named[0].arn : aws_s3_bucket.tf_state[0].arn
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = local.tf_state_bucket_id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = local.tf_state_bucket_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = local.tf_state_bucket_id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.project}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}
