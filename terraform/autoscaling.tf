resource "aws_autoscaling_group" "lmgateway" {
  name                = "lmgateway"
  vpc_zone_identifier = data.terraform_remote_state.cloudsetup.outputs.public_subnets
  desired_capacity    = 1
  max_size            = 2
  min_size            = 0
  capacity_rebalance  = true

  mixed_instances_policy {
    instances_distribution {
      on_demand_percentage_above_base_capacity = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.arm.id
        version            = "$Latest"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.arm.id
          version            = "$Latest"
        }
        instance_type = "t4g.nano"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.x86.id
          version            = "$Latest"
        }
        instance_type = "t3a.nano"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.x86.id
          version            = "$Latest"
        }
        instance_type = "t3.nano"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.x86.id
          version            = "$Latest"
        }
        instance_type = "t2.nano"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.x86.id
          version            = "$Latest"
        }
        instance_type = "t1.micro"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.arm.id
          version            = "$Latest"
        }
        instance_type = "t4g.micro"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.x86.id
          version            = "$Latest"
        }
        instance_type = "t3a.micro"
      }

      override {
        launch_template_specification {
          launch_template_id = aws_launch_template.x86.id
          version            = "$Latest"
        }
        instance_type = "t3.micro"
      }
    }
  }
}
