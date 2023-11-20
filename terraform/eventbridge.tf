data "aws_cloudwatch_event_bus" "default" {
  name = "default"
}

resource "aws_pipes_pipe" "ami_updates" {
  name     = "ami-updates"
  role_arn = aws_iam_role.ami_updates_pipes.arn
  source   = aws_sqs_queue.ami_updates.arn
  target   = data.aws_cloudwatch_event_bus.default.arn

  source_parameters {
    sqs_queue_parameters {
      batch_size = 1
    }
  }

  target_parameters {
    input_template = jsonencode({
      id = "$.id"
      account = "$.account"
      source = "mdekort.ami-updates"
      time = "$.time"
      region = "$.region"
      resources = []
      detail-type = {}
      projectName = aws_codebuild_project.lmgateway.name
    })
  }
}

resource "aws_cloudwatch_event_rule" "ami_updates" {
  name        = "capture-ami-updates"
  description = "Capture custom ami-updates events"

  event_pattern = jsonencode({
    source = ["mdekort.ami-updates"]
  })
}

resource "aws_cloudwatch_event_target" "codebuild" {
  rule      = aws_cloudwatch_event_rule.ami_updates.name
  arn       = aws_codebuild_project.lmgateway.arn
  role_arn  = aws_iam_role.ami_updates_eventbridge.arn
}
