variable "bucket_name" {}

variable "environment" {
  description = "The name of the environment"
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment)
    error_message = "Error value for environment"
  }
}



variable "aws_region" {}

variable "project" {}

variable "block_public_acls" {}

variable "block_public_policy" {}

variable "ignore_public_acls" {}

variable "restrict_public_buckets" {}

variable "bucket_key_enabled" {
  type = bool
}