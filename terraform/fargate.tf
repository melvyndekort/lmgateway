locals {
  log_configuration = var.enable_logging ? {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "ecs-default",
      awslogs-region        = "eu-west-1",
      awslogs-stream-prefix = "ami-refresher"
    }
  } : null
}

resource "aws_ecs_task_definition" "ami_refresher" {
  family                   = "ami-refresher"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ami_refresher_execution.arn
  task_role_arn            = aws_iam_role.ami_refresher_task.arn

  container_definitions = jsonencode([
    {
      name             = "ami-refresher"
      image            = "melvyndekort/ami-refresher:latest"
      essential        = true
      logConfiguration = local.log_configuration
    }
  ])

  runtime_platform {
    cpu_architecture = "ARM64"
  }
}

resource "aws_security_group" "ami_refresher" {
  name        = "ami-refresher"
  description = "ami-refresher"
  vpc_id      = data.terraform_remote_state.cloudsetup.outputs.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ami-refresher"
  }
}
