output "ansible_vault_pass" {
  value     = random_password.ansible_vault_pass.result
  sensitive = true
}
