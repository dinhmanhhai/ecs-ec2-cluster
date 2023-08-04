data "terraform_remote_state" "repository" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "repository/repository.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "ecr/ecr.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "codebuild-ecs" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "codebuild-ecs/codebuild-ecs.tfstate"
    region = var.aws_region
  }
}