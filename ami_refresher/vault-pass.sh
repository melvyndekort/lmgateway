#!/bin/sh

aws ssm get-parameter --with-decryption --name "/lmgateway/ansible_vault_password" --query "Parameter.Value" --output text
