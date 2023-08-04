variable "environment" {
  description = "The name of the environment"
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment)
    error_message = "Error value for environment"
  }
}

variable "aws_region" {}
variable "project" {}
variable "key_name" {
  description = "Key for SSH"
}
variable "aws_ami_id" {}
variable "instance_type" {}
variable "bucket_name" {}

