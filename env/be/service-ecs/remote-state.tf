data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "network/network.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "task" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "task/task.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "ecs" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "ecs/ecs.tfstate"
    region = var.aws_region
  }
}