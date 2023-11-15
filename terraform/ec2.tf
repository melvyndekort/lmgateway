data "aws_region" "current" {}

resource "aws_launch_template" "x86" {
  name          = "lmgateway-x86"
  image_id      = "ami-0abb40e211e5be214"
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

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "aws_launch_template" "arm" {
  name          = "lmgateway-arm"
  image_id      = "ami-0847665d0bad69b7a"
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

  lifecycle {
    ignore_changes = [image_id]
  }
}
