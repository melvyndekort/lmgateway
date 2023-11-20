locals {
  codebuild_name = "lmgateway-ami"
}

resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${local.codebuild_name}"
  retention_in_days = 7
  kms_key_id        = data.terraform_remote_state.cloudsetup.outputs.generic_kms_key_arn
}

resource "aws_codebuild_project" "lmgateway" {
  name = local.codebuild_name

  service_role         = aws_iam_role.ami_refresher_codebuild.arn

  badge_enabled          = true
  build_timeout          = 30
  concurrent_build_limit = 1

  source {
    type                = "GITHUB"
    location            = "https://github.com/melvyndekort/lmgateway.git"
    git_clone_depth     = 1
    report_build_status = true
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type         = "ARM_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "hashicorp/packer:latest"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.codebuild.name
    }
  }
}

#resource "aws_codebuild_webhook" "lmgateway" {
#  project_name = aws_codebuild_project.lmgateway.name
#  build_type   = "BUILD"
#
#  filter_group {
#    filter {
#      type    = "EVENT"
#      pattern = "PUSH"
#    }
#
#    filter {
#      type    = "HEAD_REF"
#      pattern = "^refs/heads/main$"
#    }
#
#    filter {
#      type    = "FILE_PATH"
#      pattern = "^ami_refresher/.+|^buildspec.yml$"
#    }
#  }
#}
