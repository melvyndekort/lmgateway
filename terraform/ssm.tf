data "aws_ssm_parameter" "ami_x86" {
  name = var.ssm_x86
}

data "aws_ssm_parameter" "ami_arm" {
  name = var.ssm_arm
}

resource "aws_ssm_parameter" "user_password" {
  name  = "/linux/user_password"
  type  = "SecureString"
  value = local.secrets.linux.user_password
}

resource "aws_ssm_parameter" "cloudflare_token" {
  name  = "/cloudflare/lmgateway_token"
  type  = "SecureString"
  value = data.terraform_remote_state.cloudsetup.outputs.api_token_lmgateway
}

resource "aws_ssm_parameter" "newrelic_key" {
  name  = "/newrelic/key"
  type  = "SecureString"
  value = data.terraform_remote_state.cloudsetup.outputs.newrelic_lmgateway_ingest_key
}
