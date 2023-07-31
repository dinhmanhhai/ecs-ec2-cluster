data "terraform_remote_state" "ecr" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "ecr/ecr.tfstate"
    region = var.aws_region
  }
}