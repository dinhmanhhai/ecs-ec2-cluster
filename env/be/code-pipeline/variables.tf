variable "branch_match" {
  type = map(any)
}

variable "aws_profile" {
  type = string
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

variable "insecure_ssl" {
  type = bool
}

variable "badge_enabled" {
  type = bool
}

variable "stage_deploy_configure" {
  type = map(any)
}
