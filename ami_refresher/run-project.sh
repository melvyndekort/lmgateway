#!/bin/sh

set -e

packer init .
packer validate .
packer build aws-lmgateway.pkr.hcl
