data "terraform_remote_state" "fe-s3" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "fe-s3/fe-s3.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "cloudwatch" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "cloudwatch/cloudwatch.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "network/network.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "repository" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "repository/repository.tfstate"
    region = var.aws_region
  }
}