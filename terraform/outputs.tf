output "ansible_vault_pass" {
  value     = random_password.ansible_vault_pass.result
  sensitive = true
}

output "codebuild_badge_url" {
  value = aws_codebuild_project.lmgateway.badge_url
}
