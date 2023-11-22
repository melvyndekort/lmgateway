.PHONY := clean build init validate plan apply trigger
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

trigger:
	@aws sqs send-message --queue-url https://sqs.eu-west-1.amazonaws.com/075673041815/ami-updates --message-body 'now go build' --delay-seconds 0 --no-cli-pager
