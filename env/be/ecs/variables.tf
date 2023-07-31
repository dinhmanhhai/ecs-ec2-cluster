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
variable "key_name" {
  description = "Key for SSH"
}
variable "aws_ami_id" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "cluster_names" {
  type = list(string)
}
variable "cluster_settings" {
  type = map(string)
}

