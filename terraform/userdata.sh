#!/bin/sh

# TODO: SSM cannot be reached over IPv6 yet, exiting
exit 0


# Retrieve New Relic license key from SSM Parameter Store
VALUE="$(aws ssm get-parameters --names /mdekort/lmgateway/newrelic_key --with-decryption --query 'Parameters[0].Value' --output text)"

# Replace the license key in the config file
sed -i "s/CHANGEME/$VALUE/g" /etc/fluent-bit/fluent-bit.conf

# Restart Fluent Bit
systemctl restart fluent-bit
