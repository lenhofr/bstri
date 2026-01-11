output "role_arn" {
  value = aws_iam_role.deploy.arn
}

output "terraform_role_arn" {
  value = var.create_terraform_role ? aws_iam_role.terraform[0].arn : null
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}
