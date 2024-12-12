.PHONY := clean build init validate plan apply tail trigger trigger-direct
.DEFAULT_GOAL := build

ifndef AWS_SESSION_TOKEN
  $(error Not logged in, please run 'awsume')
endif

clean:
	@rm -rf \
	terraform/.terraform \
	terraform/.terraform.lock.hcl

build:
	@docker image build -t melvyndekort/ami-refresher:latest ami_refresher

init:
	@terraform -chdir=terraform init

validate: init
	@terraform -chdir=terraform validate

plan: validate
	@terraform -chdir=terraform plan -input=true -refresh=true

apply: validate
	@terraform -chdir=terraform apply -input=true -refresh=true

tail:
	@aws logs tail /aws/codebuild/lmgateway-ami --follow

trigger:
	@aws sqs send-message --queue-url https://sqs.eu-west-1.amazonaws.com/075673041815/ami-updates --message-body 'now go build' --delay-seconds 0 --no-cli-pager
	@aws logs tail /aws/codebuild/lmgateway-ami --follow

trigger-direct:
	@aws codebuild start-build --project-name lmgateway-ami --no-cli-pager
	@aws logs tail /aws/codebuild/lmgateway-ami --follow

vault:
	@ansible-vault edit --vault-password-file=ami_builder/vault-pass.sh ami_builder/group_vars/all/vault.yml

clean_secrets:
	@rm -f terraform/secrets.yaml

decrypt: clean_secrets
	@aws kms decrypt \
		--ciphertext-blob $$(cat terraform/secrets.yaml.encrypted) \
		--output text \
		--query Plaintext \
		--encryption-context target=lmgateway | base64 -d > terraform/secrets.yaml

encrypt:
	@aws kms encrypt \
		--key-id alias/generic \
		--plaintext fileb://terraform/secrets.yaml \
		--encryption-context target=lmgateway \
		--output text \
		--query CiphertextBlob > terraform/secrets.yaml.encrypted
	@rm -f terraform/secrets.yaml
