#LMGATEWAY
data "aws_iam_policy_document" "lmgateway_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lmgateway" {
  name = "lmgateway"
  path = "/system/"

  assume_role_policy = data.aws_iam_policy_document.lmgateway_assume.json
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.lmgateway.id
  policy_arn = data.aws_iam_policy.ssm.arn
}

data "aws_iam_policy" "cloudwatch" {
  name = "CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.lmgateway.id
  policy_arn = data.aws_iam_policy.cloudwatch.arn
}

data "aws_iam_policy_document" "lmgateway" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = [
      aws_ssm_parameter.ansible_vault_pass.arn,
      aws_ssm_parameter.cloudflare_token.arn,
      aws_ssm_parameter.newrelic_key.arn,
    ]
  }

  statement {
    actions = [
      "s3:List*",
      "s3:GetObject*"
    ]

    resources = [
      "arn:aws:s3:::mdekort.artifacts",
      "arn:aws:s3:::mdekort.artifacts/*",
      aws_s3_bucket.ansible.arn,
      "${aws_s3_bucket.ansible.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "lmgateway" {
  role   = aws_iam_role.lmgateway.name
  policy = data.aws_iam_policy_document.lmgateway.json
}

resource "aws_iam_instance_profile" "lmgateway" {
  name = "lmgateway"
  role = aws_iam_role.lmgateway.name
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# AMI-REFRESHER
resource "aws_iam_role" "ami_refresher" {
  name = "ami_refresher"
  path = "/lambda/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "ami_refresher" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.ami_refresher.arn,
      "${aws_cloudwatch_log_group.ami_refresher.arn}:*",
    ]
  }

  statement {
    actions = [
      "ssm:GetParameter",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:ModifyLaunchTemplate",
      "ec2:DeleteLaunchTemplateVersions",
      "ec2:CreateLaunchTemplateVersion",
    ]

    resources = [
      aws_launch_template.x86.arn,
      aws_launch_template.arm.arn,
    ]
  }

  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeLaunchTemplates",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes"
    ]

    resources = [
      aws_sqs_queue.ami_updates_queue.arn,
    ]
  }
}

data "aws_iam_policy" "xray" {
  name = "AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "ami_refresher_xray" {
  role       = aws_iam_role.ami_refresher.id
  policy_arn = data.aws_iam_policy.xray.arn
}

resource "aws_iam_role_policy" "ami_refresher" {
  name   = "ami_refresher"
  role   = aws_iam_role.ami_refresher.id
  policy = data.aws_iam_policy_document.ami_refresher.json
}
