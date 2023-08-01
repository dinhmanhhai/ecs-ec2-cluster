terraform {
  backend "s3" {
    bucket = "haidm-infra-remote-state"
    key    = "fe-s3/fe-s3.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}
provider "aws" {
  region              = var.aws_region
  profile             = var.aws_profile
  shared_config_files = [" ~/.aws/credentials"]

  default_tags {
    tags = {
      Environment = "${var.project}_${var.environment}"
    }
  }
}
