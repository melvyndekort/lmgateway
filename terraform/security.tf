resource "aws_security_group" "lmgateway" {
  name        = "lmgateway"
  description = "SSH jump hosts"
  vpc_id      = data.terraform_remote_state.tf_aws.outputs.vpc_id

  tags = {
    Name = "lmgateway"
  }
}

resource "aws_security_group_rule" "lmgateway_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.lmgateway.id
  description       = "All outgoing traffic"
}

resource "aws_security_group_rule" "eice_lmgateway_egress" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lmgateway.id
  security_group_id        = data.terraform_remote_state.tf_aws.outputs.eice_security_group_id
  description              = "SSH traffic to lmgateway"
}

resource "aws_security_group_rule" "eice_lmgateway_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.tf_aws.outputs.eice_security_group_id
  security_group_id        = aws_security_group.lmgateway.id
  description              = "SSH traffic from EICE"
}

resource "aws_security_group_rule" "lmgateway_home" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  ipv6_cidr_blocks  = ["2a02:a45b:51f6::/48"]
  security_group_id = aws_security_group.lmgateway.id
  description       = "IPv6 traffic from home network"
}
