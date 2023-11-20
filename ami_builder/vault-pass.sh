#!/bin/sh

aws ssm get-parameter --with-decryption --name "/mdekort/lmgateway/ansible_vault_password" --query "Parameter.Value" --output text
