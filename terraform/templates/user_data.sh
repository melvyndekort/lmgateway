#!/bin/sh

dnf install -y python3 python3-pip ansible
pip install boto3

aws configure set default.region eu-west-1
aws s3 cp --endpoint-url https://s3.dualstack.eu-west-1.amazonaws.com --recursive s3://${ANSIBLE_S3_BUCKET}/lmgateway/ /tmp/ansible/

export SSM_ANSIBLE_VAULT_PASS=${SSM_ANSIBLE_VAULT_PASS}
export SSM_NEWRELIC_KEY=${SSM_NEWRELIC_KEY}
ansible-playbook /tmp/ansible/playbook.yml
