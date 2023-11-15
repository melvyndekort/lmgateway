packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "lmgateway_x86_64" {
  ami_name      = "mdekort-lmgateway-x86_64"
  instance_type = "t3a.small"
  region        = "eu-west-1"

  source_ami_filter {
    filters = {
      architecture        = "x86_64"
      name                = "al202?-ami-minimal-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    encrypted   = true
    kms_key_id  = "alias/generic"
  }

  associate_public_ip_address = true
  iam_instance_profile        = "ami-refresher-installer"
  ssh_username                = "ec2-user"
  force_deregister            = true
  force_delete_snapshot       = true
}

source "amazon-ebs" "lmgateway_arm64" {
  ami_name      = "mdekort-lmgateway-arm64"
  instance_type = "t4g.small"
  region        = "eu-west-1"

  source_ami_filter {
    filters = {
      architecture        = "arm64"
      name                = "al202?-ami-minimal-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["137112412989"]
  }

  subnet_filter {
    filters = {
      "tag:Name" : "generic-public-*"
    }
    most_free = true
  }

  launch_block_device_mappings {
    device_name = "/dev/xvda"
    encrypted   = true
    kms_key_id  = "alias/generic"
  }

  associate_public_ip_address = true
  iam_instance_profile        = "ami-refresher-installer"
  ssh_username                = "ec2-user"
  force_deregister            = true
  force_delete_snapshot       = true
}

build {
  sources = [
    "source.amazon-ebs.lmgateway_x86_64",
    "source.amazon-ebs.lmgateway_arm64"
  ]

  provisioner "shell" {
    inline = [
      "sudo dnf install -y ansible aws-cli python3 python3-pip",
      "pip install --user boto3"
    ]
  }

  provisioner "ansible-local" {
    playbook_file   = "./playbook.yml"
    playbook_dir    = "."
    extra_arguments = ["--vault-password-file=./vault-pass.sh"]
  }
}
