data "terraform_remote_state" "fe_s3" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = "fe-s3/fe-s3.tfstate"
    region = var.aws_region
  }
}
