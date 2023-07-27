#data "terraform_remote_state" "network" {
#  backend = "s3"
#  config = {
#    bucket = var.bucket_name
#    key    = "network/network.tfstate"
#    region = var.aws_region
#  }
#}