# LMGATEWAY

## Badges

### Workflows

![CodeBuild](https://codebuild.eu-west-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiODJxdnFrSG5OMUFuUDBZZm5mRmp6ak1aZER1anVtdHIrM1RiMW5vL1pwT0tzUkt6MkxJN2p0bS9WcnpOWmdnNEJocTFOU00rU05jeFFyMXprN1BRRFVVPSIsIml2UGFyYW1ldGVyU3BlYyI6IkFDdjdaQXJvWjFuSUE1TEciLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=main)
[![Terraform](https://github.com/melvyndekort/lmgateway/actions/workflows/terraform.yml/badge.svg)](https://github.com/melvyndekort/lmgateway/actions/workflows/terraform.yml)
[![Ansible-lint](https://github.com/melvyndekort/lmgateway/actions/workflows/ansible-lint.yml/badge.svg)](https://github.com/melvyndekort/lmgateway/actions/workflows/ansible-lint.yml)

## Purpose

A simple EC2 jumphost setup which connects home via Wireguard.

The AMI is built using AWS CodeBuild and Hashicorp Packer, the build gets triggered by commits to this repository and by an SNS topic subscription. The SNS topic receives updates when AWS publishes a new Amazon Linux 2023 AMI version.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
