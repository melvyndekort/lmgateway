resource "aws_codebuild_project" "lmgateway" {
  name = "lmgateway-ami"

  service_role         = aws_iam_role.ami_refresher_task.arn
  resource_access_role = aws_iam_role.ami_refresher_execution.arn

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

  #logs_config {
  #  cloudwatch_logs {
  #    group_name  = null
  #    stream_name = null
  #  }
  #}
}

resource "aws_codebuild_webhook" "lmgateway" {
  project_name = aws_codebuild_project.lmgateway.name
  build_type   = "BUILD"

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }

    filter {
      type    = "BASE_REF"
      pattern = "^refs/heads/main$"
    }

    filter {
      type    = "FILE_PATH"
      pattern = "^ami_refresher/.+|^buildspec.yml$"
    }
  }
}
