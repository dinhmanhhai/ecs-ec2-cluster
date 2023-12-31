data "terraform_remote_state" "repository" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "repository/repository.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "fe-s3" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "fe-s3/fe-s3.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "fe-codebuild" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "fe-codebuild/fe-codebuild.tfstate"
    region = var.aws_region
  }
}