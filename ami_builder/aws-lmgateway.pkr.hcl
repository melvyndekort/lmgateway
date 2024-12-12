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
  region              = "eu-west-1"
  ami_name            = "mdekort-lmgateway-x86_64"
  spot_instance_types = ["t3a.small", "t3.small", "t2.small", "t2.medium"]
  spot_price          = "auto"

  imds_support = "v2.0"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional"
  }

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

  subnet_filter {
    filters = {
      "tag:Name" : "generic-public-*"
    }
    most_free = true
  }

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    encrypted             = true
    volume_size           = 16
  }

  tags = {
    Name = "mdekort-lmgateway-x86_64"
    Base_AMI_ID = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }

  fleet_tags = {
    Name = "Packer Builder"
  }

  associate_public_ip_address = true
  iam_instance_profile        = "lmgateway-installer"
  ssh_username                = "ec2-user"
  force_deregister            = true
  force_delete_snapshot       = true
}

source "amazon-ebs" "lmgateway_arm64" {
  region              = "eu-west-1"
  ami_name            = "mdekort-lmgateway-arm64"
  spot_instance_types = ["t4g.small", "t4g.medium"]
  spot_price          = "auto"

  imds_support = "v2.0"

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "optional"
  }

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
    device_name           = "/dev/xvda"
    delete_on_termination = true
    encrypted             = true
    volume_size           = 16
  }

  tags = {
    Name = "mdekort-lmgateway-arm64"
    Base_AMI_ID = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }

  fleet_tags = {
    Name = "Packer Builder"
  }

  associate_public_ip_address = true
  iam_instance_profile        = "lmgateway-installer"
  ssh_username                = "ec2-user"
  force_deregister            = true
  force_delete_snapshot       = true
}

build {
  sources = [
    "source.amazon-ebs.lmgateway_x86_64",
    "source.amazon-ebs.lmgateway_arm64"
  ]

  provisioner "ansible" {
    galaxy_file     = "./requirements.yml"
    playbook_file   = "./site.yml"
    extra_arguments = ["--vault-password-file=./vault-pass.sh"]
  }
}
