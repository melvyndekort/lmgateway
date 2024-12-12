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

data "aws_iam_policy_document" "events_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}


# SQS -> PIPES -> EVENTBRIDGE
resource "aws_iam_role" "ami_updates_pipes" {
  name               = "ami-updates-pipes"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.pipes_assume.json
}

data "aws_iam_policy_document" "ami_updates_pipes" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    resources = [
      aws_sqs_queue.ami_updates.arn,
    ]
  }
  statement {
    actions = [
      "events:PutEvents",
    ]
    resources = [
      data.aws_cloudwatch_event_bus.default.arn,
    ]
  }
}

resource "aws_iam_role_policy" "ami_updates_pipes" {
  role   = aws_iam_role.ami_updates_pipes.name
  policy = data.aws_iam_policy_document.ami_updates_pipes.json
}


# EVENTBRIDGE -> CODEBUILD
resource "aws_iam_role" "ami_updates_eventbridge" {
  name               = "ami-updates-eventbridge"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.events_assume.json
}

data "aws_iam_policy_document" "ami_updates_eventbridge" {
  statement {
    actions = [
      "codebuild:StartBuild",
    ]
    resources = [
      aws_codebuild_project.lmgateway.arn,
    ]
  }
  statement {
    actions = [
      "sqs:SendMessage"
    ]
    resources = [
      aws_sqs_queue.ami_updates_dlq.arn
    ]
  }
}

resource "aws_iam_role_policy" "ami_updates_eventbridge" {
  role   = aws_iam_role.ami_updates_eventbridge.name
  policy = data.aws_iam_policy_document.ami_updates_eventbridge.json
}


# CODEBUILD TASK
resource "aws_iam_role" "codebuild" {
  name               = "lmgateway-codebuild"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume.json
}

data "aws_iam_policy_document" "codebuild" {
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
      "autoscaling:StartInstanceRefresh"
    ]
    resources = [
      aws_autoscaling_group.lmgateway.arn,
    ]
  }
  statement {
    actions = [
      "iam:GetInstanceProfile"
    ]
    resources = [
      aws_iam_instance_profile.installer.arn
    ]
  }
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.installer.arn
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.codebuild.arn,
      "${aws_cloudwatch_log_group.codebuild.arn}:*",
    ]
  }
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.github_api_token.arn,
      aws_ssm_parameter.ansible_vault_pass.arn,
    ]
  }
  statement {
    actions = [
      "ssm:PutParameter",
    ]
    resources = [
      aws_ssm_parameter.ami_x86_64.arn,
      aws_ssm_parameter.ami_arm64.arn,
    ]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  role   = aws_iam_role.codebuild.name
  policy = data.aws_iam_policy_document.codebuild.json
}


# AMI-REFRESHER INSTALLER
resource "aws_iam_role" "installer" {
  name = "lmgateway-installer"
  path = "/system/"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_instance_profile" "installer" {
  name = "lmgateway-installer"
  role = aws_iam_role.installer.name
}

data "aws_iam_policy_document" "installer" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      aws_ssm_parameter.newrelic_key.arn,
    ]
  }
}

resource "aws_iam_role_policy" "installer" {
  role   = aws_iam_role.installer.name
  policy = data.aws_iam_policy_document.installer.json
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
