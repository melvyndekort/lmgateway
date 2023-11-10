FROM hashicorp/packer:1.9

RUN apk add --update --no-cache aws-cli

COPY aws-lmgateway.pkr.hcl /workspace/
COPY playbook.yml /workspace/
COPY secrets.yml /workspace/
COPY vault-pass.sh /workspace/
COPY roles /workspace/

COPY run-project.sh /usr/local/bin/

WORKDIR "/workspace"

ENTRYPOINT []

CMD [ "run-project.sh" ]
