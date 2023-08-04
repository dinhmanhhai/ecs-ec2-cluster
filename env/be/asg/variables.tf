variable "environment" {
  description = "The name of the environment"
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment)
    error_message = "Error value for environment"
  }
}



variable "aws_region" {}

variable "project" {}

variable "bucket_name" {}
variable "aws_ami_id" {}
variable "key_name" {}
variable "instance_type" {}
variable "cluster_names" {}
variable "volume_type" {}