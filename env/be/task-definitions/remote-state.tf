data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "ecr/ecr.tfstate"
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

data "terraform_remote_state" "iam" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "iam/iam.tfstate"
    region = var.aws_region
  }
}