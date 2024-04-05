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
}

resource "aws_cloudwatch_event_rule" "ami_updates" {
  name        = "pipe-ami-updates"
  description = "Capture event emitted by ${aws_pipes_pipe.ami_updates.name}"

  event_pattern = jsonencode({
    source      = ["Pipe ${aws_pipes_pipe.ami_updates.name}"]
    detail-type = ["Event from aws:sqs"]
  })
}

resource "aws_cloudwatch_event_target" "codebuild" {
  rule     = aws_cloudwatch_event_rule.ami_updates.name
  arn      = aws_codebuild_project.lmgateway.arn
  role_arn = aws_iam_role.ami_updates_eventbridge.arn

  dead_letter_config {
    arn = aws_sqs_queue.ami_updates_dlq.arn
  }

  retry_policy {
    maximum_event_age_in_seconds = 3600
    maximum_retry_attempts       = 30
  }

  input = "{}"
}
