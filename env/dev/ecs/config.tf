terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  shared_config_files = [" ~/.aws/credentials"]

  default_tags {
    tags = {
      Environment = "${var.project}_${var.environment}"
    }
  }
}
