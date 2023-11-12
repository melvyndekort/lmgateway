data "aws_ssm_parameter" "ami_x86" {
  name = var.ssm_x86
}

data "aws_ssm_parameter" "ami_arm" {
  name = var.ssm_arm
}

resource "random_password" "ansible_vault_pass" {
  length  = 40
  special = true
}

resource "aws_ssm_parameter" "ansible_vault_pass" {
  name  = "/lmgateway/ansible_vault_password"
  type  = "SecureString"
  value = random_password.ansible_vault_pass.result
}

resource "aws_ssm_parameter" "cloudflare_token" {
  name  = "/lmgateway/cloudflare_token"
  type  = "SecureString"
  value = data.terraform_remote_state.cloudsetup.outputs.api_token_lmgateway
}

resource "aws_ssm_parameter" "newrelic_key" {
  name  = "/lmgateway/newrelic_key"
  type  = "SecureString"
  value = data.terraform_remote_state.cloudsetup.outputs.newrelic_lmgateway_ingest_key
}
