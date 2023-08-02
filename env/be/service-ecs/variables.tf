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

variable "bucket_name" {}

variable "container_port_mapping" {}

variable "assign_public_ip_for_tasks" {
  type = bool
}

variable "cluster_names" {
  type = list(string)
}