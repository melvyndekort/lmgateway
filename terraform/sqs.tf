resource "aws_sqs_queue" "ami_updates" {
  name          = "ami-updates"
  delay_seconds = 900
}

data "aws_iam_policy_document" "ami_updates" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.ami_updates.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "ami_updates" {
  queue_url = aws_sqs_queue.ami_updates.id
  policy    = data.aws_iam_policy_document.ami_updates.json
}

resource "aws_sns_topic_subscription" "ami_updates_sqs_target" {
  provider = aws.snsregion

  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.ami_updates.arn
}

resource "aws_sns_topic_subscription" "ami_updates_email_target" {
  provider = aws.snsregion

  topic_arn = var.sns_topic_arn
  protocol  = "email"
  endpoint  = "melvyn@mdekort.nl"
}
