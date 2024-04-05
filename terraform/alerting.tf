locals {
  alarm_topic_arn = data.terraform_remote_state.cloudsetup.outputs.alerting_sns_arn
  notifications_topic_arn = data.terraform_remote_state.cloudsetup.outputs.notifications_sns_arn
}

resource "aws_cloudwatch_metric_alarm" "ami_updates_dlq_alarm" {
  alarm_name          = "ami_updates_dlq_alarm"
  statistic           = "Sum"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 300
  evaluation_periods  = 2
  namespace           = "AWS/SQS"
  dimensions = {
    QueueName = aws_sqs_queue.ami_updates_dlq.name
  }
  alarm_actions = [local.alarm_topic_arn]
  ok_actions    = [local.alarm_topic_arn]
}

resource "aws_codestarnotifications_notification_rule" "build_status" {
  name        = "lmgateway-ami-update-notifications"
  resource    = aws_codebuild_project.lmgateway.arn
  detail_type = "BASIC"

  event_type_ids = [
    "codebuild-project-build-state-failed",
    "codebuild-project-build-state-succeeded",
    "codebuild-project-build-state-in-progress",
    "codebuild-project-build-state-stopped"
  ]

  target {
    address = local.notifications_topic_arn
  }
}

resource "aws_cloudwatch_metric_alarm" "lmgateway_alive_alarm" {
  alarm_name          = "lmgateway-alive-alarm"
  statistic           = "Average"
  metric_name         = "GroupInServiceInstances"
  comparison_operator = "LessThanThreshold"
  threshold           = 0.8
  period              = 300
  evaluation_periods  = 2
  namespace           = "AWS/AutoScaling"
  treat_missing_data  = "breaching"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.lmgateway.name
  }
  alarm_actions = [local.alarm_topic_arn]
  ok_actions    = [local.alarm_topic_arn]
}
