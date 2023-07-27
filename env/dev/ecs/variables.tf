variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
  default = {
    public  = 4,
    private = 4
  }
}

variable "environment" {
  description = "The name of the environment"
}

variable "num_of_azs" {
  description = "Number of az"
}

variable "vpc_cidr" {}

variable "project" {}

variable "private_subnet_cidrs" {
  type = list(any)
}

variable "public_subnet_cidrs" {
  type = list(any)
}

variable "aws_profile" {
  description = "The AWS-CLI profile for the account to create resources in."
}

variable "aws_region" {}