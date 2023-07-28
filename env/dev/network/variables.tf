variable "subnet_count" {
  description = "Number of subnets"
  type        = map(number)
}

variable "environment" {
  description = "The name of the environment"
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment)
    error_message = "Error value for environment"
  }
}

variable "aws_profile" {
  description = "The AWS-CLI profile for the account to create resources in."
}

variable "aws_region" {}

variable "project" {}

variable "num_of_azs" {
  description = "Number of az"
}

variable "vpc_cidr" {}

variable "private_subnet_cidrs" {
  type = list(any)
}

variable "public_subnet_cidrs" {
  type = list(any)
}

variable "bucket_name" {}
