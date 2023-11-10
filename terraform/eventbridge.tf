resource "aws_pipes_pipe" "ami_refresher" {
  name     = "ami-refresher"
  role_arn = aws_iam_role.ami_refresher_pipes.arn
  source   = aws_sqs_queue.ami_updates_queue.arn
  target   = data.terraform_remote_state.cloudsetup.outputs.ecs_cluster_arn

  source_parameters {
    sqs_queue_parameters {
      batch_size                         = 1
      maximum_batching_window_in_seconds = 2
    }
  }

  target_parameters {
    ecs_task_parameters {
      launch_type         = "FARGATE"
      task_definition_arn = aws_ecs_task_definition.ami_refresher.arn
      task_count          = 1

      network_configuration {
        aws_vpc_configuration {
          subnets          = data.terraform_remote_state.cloudsetup.outputs.public_subnets
          security_groups  = [aws_security_group.ami_refresher.id]
          assign_public_ip = "ENABLED"
        }
      }
    }
  }
}
