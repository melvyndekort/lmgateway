resource "aws_cloudwatch_log_group" "ami_refresher" {
  name              = "/aws/lambda/ami-refresher"
  retention_in_days = 7
  kms_key_id        = data.terraform_remote_state.cloudsetup.outputs.generic_kms_key_arn
}

data "archive_file" "empty_lambda" {
  type        = "zip"
  output_path = "lambda.zip"

  source {
    filename = "ami_refresher/handler.py"
    content  = <<EOF
def handle(event, context):
  raise NotImplementedError
EOF
  }
}

resource "aws_lambda_function" "ami_refresher" {
  function_name = "ami-refresher"
  role          = aws_iam_role.ami_refresher.arn
  handler       = "ami_refresher.handler.handle"

  filename         = data.archive_file.empty_lambda.output_path
  source_code_hash = data.archive_file.empty_lambda.output_base64sha256

  layers = [
    "arn:aws:lambda:eu-west-1:901920570463:layer:aws-otel-python-arm64-ver-1-20-0:2",
  ]

  runtime       = "python3.9"
  architectures = ["arm64"]
  memory_size   = 128
  timeout       = 8

  tracing_config {
    mode = "Active"
  }

  kms_key_arn = data.terraform_remote_state.cloudsetup.outputs.generic_kms_key_arn

  environment {
    variables = {
      AMI_PARAM_PATH_X86      = data.aws_ssm_parameter.ami_x86.name
      AMI_PARAM_PATH_ARM64    = data.aws_ssm_parameter.ami_arm.name
      TEMPLATE_ARN_X86        = aws_launch_template.x86.id
      TEMPLATE_ARN_ARM        = aws_launch_template.arm.id
      AWS_LAMBDA_EXEC_WRAPPER = "/opt/otel-instrument"
    }
  }

  depends_on = [
    aws_iam_role_policy.ami_refresher,
    aws_cloudwatch_log_group.ami_refresher,
  ]

  lifecycle {
    ignore_changes = [source_code_hash]
  }
}

resource "aws_lambda_event_source_mapping" "ami_refresher" {
  event_source_arn = aws_sqs_queue.ami_updates_queue.arn
  function_name    = aws_lambda_function.ami_refresher.arn

  depends_on = [
    aws_iam_role.ami_refresher,
  ]
}
