output "state_bucket_name" {
  value = local.tf_state_bucket_name
}

output "lock_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}

output "region" {
  value = var.region
}
