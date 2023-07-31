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

variable "deregistration_delay" {
  default = "300"
}
variable "health_check_path" {}
variable "path_mapping" {}
variable "target_type" {
  type = string
  validation {
    condition     = contains(["instance", "lambda", "ip"], var.target_type)
    error_message = "Error value for target_type"
  }
}