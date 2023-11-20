# ASSUME POLICIES
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "pipes_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["pipes.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "codebuild.amazonaws.com"]
    }
  }
}


# SQS -> PIPES -> FARGATE
resource "aws_iam_role" "ami_refresher_pipes" {
  name               = "ami-refresher-pipes"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.pipes_assume.json
}

data "aws_iam_policy_document" "ami_refresher_pipes" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    resources = [
      aws_sqs_queue.ami_updates_queue.arn,
    ]
  }
  statement {
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ami_refresher_execution.arn,
      aws_iam_role.ami_refresher_task.arn,
    ]
  }
}

resource "aws_iam_role_policy" "ami_refresher_pipes" {
  role   = aws_iam_role.ami_refresher_pipes.name
  policy = data.aws_iam_policy_document.ami_refresher_pipes.json
}


# AMI-REFRESHER EXECUTION
resource "aws_iam_role" "ami_refresher_execution" {
  name               = "ami-refresher-execution"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy" "ami_refresher_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ami_refresher_execution" {
  policy_arn = data.aws_iam_policy.ami_refresher_execution.arn
  role       = aws_iam_role.ami_refresher_execution.name
}


# AMI-REFRESHER TASK
resource "aws_iam_role" "ami_refresher_task" {
  name               = "ami-refresher-task"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "ami_refresher_task" {
  statement {
    actions = [
      "ec2:*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "iam:GetInstanceProfile"
    ]
    resources = [
      aws_iam_instance_profile.ami_refresher_installer.arn
    ]
  }
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.ami_refresher_installer.arn
    ]
  }
  statement {
    actions = [
      "ssm:PutParameter",
    ]
    resources = [
      aws_ssm_parameter.ami_x86_64.arn,
      aws_ssm_parameter.ami_arm64.arn
    ]
  }
}

resource "aws_iam_role_policy" "ami_refresher_task" {
  role   = aws_iam_role.ami_refresher_task.name
  policy = data.aws_iam_policy_document.ami_refresher_task.json
}


# AMI-REFRESHER INSTALLER
resource "aws_iam_role" "ami_refresher_installer" {
  name = "ami-refresher-installer"
  path = "/system/"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_instance_profile" "ami_refresher_installer" {
  name = "ami-refresher-installer"
  role = aws_iam_role.ami_refresher_installer.name
}

data "aws_iam_policy_document" "ami_refresher_installer" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      aws_ssm_parameter.ansible_vault_pass.arn,
      aws_ssm_parameter.newrelic_key.arn,
    ]
  }
}

resource "aws_iam_role_policy" "ami_refresher_installer" {
  role   = aws_iam_role.ami_refresher_installer.name
  policy = data.aws_iam_policy_document.ami_refresher_installer.json
}


# LMGATEWAY
resource "aws_iam_role" "lmgateway" {
  name = "lmgateway"
  path = "/system/"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_instance_profile" "lmgateway" {
  name = "lmgateway"
  role = aws_iam_role.lmgateway.name
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.lmgateway.id
  policy_arn = data.aws_iam_policy.ssm.arn
}

data "aws_iam_policy_document" "lmgateway" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      aws_ssm_parameter.ami_x86_64.arn,
      aws_ssm_parameter.ami_arm64.arn
    ]
  }
}

resource "aws_iam_role_policy" "lmgateway" {
  role   = aws_iam_role.lmgateway.name
  policy = data.aws_iam_policy_document.lmgateway.json
}
