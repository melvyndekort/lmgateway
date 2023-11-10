data "aws_region" "current" {}

resource "aws_launch_template" "x86" {
  name          = "lmgateway-x86"
  image_id      = "resolve:ssm:/mdekort/lmgateway/ami/x86_64"
  instance_type = "t3a.nano"

  update_default_version = true

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

  depends_on = [aws_ssm_parameter.ami_x86_64]
}

resource "aws_launch_template" "arm" {
  name          = "lmgateway-arm"
  image_id      = "resolve:ssm:/mdekort/lmgateway/ami/arm64"
  instance_type = "t4g.nano"

  update_default_version = true

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

  depends_on = [aws_ssm_parameter.ami_arm64]
}
