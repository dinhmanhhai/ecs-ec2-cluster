variable "environment" {
  description = "The name of the environment"
  type        = string
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

variable "cluster_names" {
  type = list(string)
}

variable "branch_match" {
  type = map(any)
}

variable "insecure_ssl" {
  type = bool
}

variable "privileged_mode" {
  type = bool
}

variable "badge_enabled" {
  type = bool
}

variable "build_timeout" {
  type = string
}

variable "cache_bucket_name" {
  type = string
}

variable "artifacts_type" {
  type = string
}

variable "ecr_names" {
  type = list(string)
}

variable "env_vars" {
  type = any
}
