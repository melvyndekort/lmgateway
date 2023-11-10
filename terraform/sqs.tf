resource "aws_sqs_queue" "ami_updates_queue" {
  name          = "ami-updates-queue"
  delay_seconds = 900
}

data "aws_iam_policy_document" "ami_updates_queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ami_updates_queue.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "ami_updates_queue" {
  queue_url = aws_sqs_queue.ami_updates_queue.id
  policy    = data.aws_iam_policy_document.ami_updates_queue.json
}

resource "aws_sns_topic_subscription" "ami_updates_sqs_target" {
  provider = aws.snsregion

  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ami_updates_queue.arn
}

resource "aws_sns_topic_subscription" "ami_updates_email_target" {
  provider = aws.snsregion

  topic_arn = var.sns_topic_arn
  protocol  = "email"
  endpoint  = "melvyn@mdekort.nl"
}
