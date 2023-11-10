resource "random_password" "ansible_vault_pass" {
  length  = 40
  special = true
}

resource "aws_ssm_parameter" "ansible_vault_pass" {
  name  = "/mdekort/lmgateway/ansible_vault_password"
  type  = "SecureString"
  value = random_password.ansible_vault_pass.result
}

resource "aws_ssm_parameter" "newrelic_key" {
  name  = "/mdekort/lmgateway/newrelic_key"
  type  = "SecureString"
  value = data.terraform_remote_state.cloudsetup.outputs.newrelic_lmgateway_ingest_key
}

resource "aws_ssm_parameter" "ami_x86_64" {
  name           = "/mdekort/lmgateway/ami/x86_64"
  type           = "String"
  data_type      = "aws:ec2:image"
  insecure_value = "ami-0abb40e211e5be214"

  lifecycle {
    ignore_changes = [insecure_value]
  }
}

resource "aws_ssm_parameter" "ami_arm64" {
  name           = "/mdekort/lmgateway/ami/arm64"
  type           = "String"
  data_type      = "aws:ec2:image"
  insecure_value = "ami-0847665d0bad69b7a"

  lifecycle {
    ignore_changes = [insecure_value]
  }
}
