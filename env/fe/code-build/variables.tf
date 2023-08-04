variable "branch_match" {
  type = map(any)
}
variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "build_timeout" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "cache_bucket_name" {
  type = string
}

variable "insecure_ssl" {
  type = bool
}

variable "badge_enabled" {
  type = bool
}