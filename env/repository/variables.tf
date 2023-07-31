variable "environment" {
default = "dev"
}

variable "aws_profile" {
  description = "The AWS-CLI profile for the account to create resources in."
  default = "default"
}

variable "aws_region" {
  default = "us-east-1"
}