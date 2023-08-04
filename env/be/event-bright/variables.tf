variable "environment" {
  description = "The name of the environment"
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment)
    error_message = "Error value for environment"
  }
}

variable "aws_region" {
  type = string
}
variable "project" {
  type = string
}
variable "bucket_name" {
  type = string
}
variable "branch_match" {
  type = map(any)
}
