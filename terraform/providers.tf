terraform {
  required_version = "~> 1.5.0"

  backend "s3" {
    bucket = "mdekort.tfstate"
    key    = "lmgateway.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.8.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "aws" {
  region = var.sns_topic_region
  alias  = "snsregion"
}
