resource "aws_key_pair" "melvyn" {
  key_name   = "melvyn"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCse8TLb47f+zddmzm0EvO6+RK8eeQouClEFA33ftG6+ioiJxkNf+vXwtWVlmA4JzwhLDQ5tKk+SQ9OTg/JMB8O9VfaK9LHxhJhLdiNo+P8W/vK9BI6CNCA1F+rbzN3OtEavYum7eHxeUrnYM+VkGyUpi5zmbHYF30VgxYeLMoK66eriFo+EHoQwv137uUgGYxe1BLGwkHjWdZ6wgjPkZTu4QoAsdxptVZH16TsFJKEQJdetJbJQ+I86yPjZ4AU5ImzdWUbUA4ic8gIZDhZeLz2UCmRB/EilNVKzQb+m54rE+cRH7f63zcEkqnAb5Ugz+XRMtdtqxcx2x9Eza2ohk8ZblyE8s3D2c4KR4YKzZJhuakK/sQ9FKOJo6vy2G6Mq1PMUhMF3rn+whUzXBpV2A0XK8P0H7/D+7zsGnQH+NZb6akgE+SqonL+zK430xWhWvoE7irtPh9CeG8+AF9OD+nbGBs22HpXCeR+yW2tPfJQtHLBOkaWyzJIsqfl4cMWaCRMnRKl/QEJuu9dG3rtOcZyBvkBnKd0X1GNIN5t1BMuhKghkipBgrG2oMM3hBRafHafrg26ikIImuImqVvaWZWeKKjU5tsivu/PELa4vyF/PqJ7meFqf1V2Jpw2Z21nSVQsgXK34Kbx5r6GSIdea+9cdEsJabKS7VrqwmSY8NjCZQ=="
}

data "aws_region" "current" {}

data "template_file" "x86" {
  template = file("${path.module}/templates/lmgateway.sh")

  vars = {
    arch             = "x86_64"
    region           = data.aws_region.current.name
    hosted_zone_id   = data.terraform_remote_state.cloudsetup.outputs.mdekort_zone_id
    hosted_zone_name = "mdekort.nl"
    private_key      = local.secrets.wireguard.gw_private_key
    public_key       = local.secrets.wireguard.lmrouter_public_key
    user_password    = local.secrets.linux.user_password
    cloudflare_token = aws_ssm_parameter.cloudflare_token.name
    newrelic_key     = aws_ssm_parameter.newrelic_key.name
  }
}

data "template_file" "arm" {
  template = file("${path.module}/templates/lmgateway.sh")

  vars = {
    arch             = "arm64"
    region           = data.aws_region.current.name
    hosted_zone_id   = data.terraform_remote_state.cloudsetup.outputs.mdekort_zone_id
    hosted_zone_name = "mdekort.nl"
    private_key      = local.secrets.wireguard.gw_private_key
    public_key       = local.secrets.wireguard.lmrouter_public_key
    user_password    = local.secrets.linux.user_password
    cloudflare_token = aws_ssm_parameter.cloudflare_token.name
    newrelic_key     = aws_ssm_parameter.newrelic_key.name
  }
}

resource "aws_launch_template" "x86" {
  name          = "lmgateway-x86"
  image_id      = data.aws_ssm_parameter.ami_x86.value
  instance_type = "t3a.nano"

  update_default_version = true

  user_data = base64encode(data.template_file.x86.rendered)

  network_interfaces {
    security_groups = [aws_security_group.lmgateway.id]

    associate_public_ip_address = false
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.lmgateway.arn
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "lmgateway"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "lmgateway"
    }
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = {
      Name = "lmgateway"
    }
  }

  tag_specifications {
    resource_type = "spot-instances-request"

    tags = {
      Name = "lmgateway"
    }
  }

  lifecycle {
    ignore_changes = [description]
  }
}

resource "aws_launch_template" "arm" {
  name          = "lmgateway-arm"
  image_id      = data.aws_ssm_parameter.ami_arm.value
  instance_type = "t4g.nano"

  update_default_version = true

  user_data = base64encode(data.template_file.arm.rendered)

  network_interfaces {
    security_groups = [aws_security_group.lmgateway.id]

    associate_public_ip_address = false
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.lmgateway.arn
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "lmgateway"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "lmgateway"
    }
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = {
      Name = "lmgateway"
    }
  }

  tag_specifications {
    resource_type = "spot-instances-request"

    tags = {
      Name = "lmgateway"
    }
  }

  lifecycle {
    ignore_changes = [description]
  }
}
