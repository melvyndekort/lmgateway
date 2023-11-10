#!/bin/sh

set -e

packer init .
packer validate .
packer build -color=false aws-lmgateway.pkr.hcl

# Configure AWS CLI
aws configure set default.region eu-west-1

# Update x86 AMI
ami_x86="$(aws ec2 describe-images \
  --filters 'Name=name,Values=mdekort-lmgateway-x86_64' \
  --query 'Images[*].ImageId' \
  --output text)"
aws ssm put-parameter \
  --name '/mdekort/lmgateway/ami/x86_64' \
  --value "$ami_x86" \
  --overwrite

# Update arm AMI
ami_arm="$(aws ec2 describe-images \
  --filters 'Name=name,Values=mdekort-lmgateway-arm64' \
  --query 'Images[*].ImageId' \
  --output text)"
aws ssm put-parameter \
  --name '/mdekort/lmgateway/ami/arm64' \
  --value "$ami_arm" \
  --overwrite

# Terminate instances
instance_ids="$(aws ec2 describe-instances \
  --filters 'Name=tag:Name,Values=lmgateway' \
  --query 'Reservations[*].Instances[*].[InstanceId]' \
  --output text)"
aws ec2 terminate-instances --instance-ids "$instance_ids"
