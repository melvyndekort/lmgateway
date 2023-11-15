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

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


# LMGATEWAY INSTALLER
resource "aws_iam_role" "lmgateway_installer" {
  name = "lmgateway-installer"
  path = "/system/"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

resource "aws_iam_instance_profile" "lmgateway_installer" {
  name = "lmgateway-installer"
  role = aws_iam_role.lmgateway_installer.name
}

data "aws_iam_policy_document" "lmgateway_installer" {
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

resource "aws_iam_role_policy" "lmgateway_installer" {
  role   = aws_iam_role.lmgateway_installer.name
  policy = data.aws_iam_policy_document.lmgateway_installer.json
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


# AMI-REFRESHER
resource "aws_iam_role" "ami_refresher" {
  name = "ami_refresher"
  path = "/lambda/"

  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
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
      "ec2:*",
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

resource "aws_iam_role_policy" "ami_refresher" {
  name   = "ami_refresher"
  role   = aws_iam_role.ami_refresher.id
  policy = data.aws_iam_policy_document.ami_refresher.json
}
