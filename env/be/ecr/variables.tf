variable "environment" {
  description = "The name of the environment"
  validation {
    condition     = contains(["prod", "stg", "dev"], var.environment)
    error_message = "Error value for environment"
  }
}

variable "aws_region" {}
variable "project" {}
variable "ecr_names" {}
variable "image_mutability" {
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_mutability)
    error_message = "Error value for image_mutability"
  }
}
variable "encryption_type" {}
