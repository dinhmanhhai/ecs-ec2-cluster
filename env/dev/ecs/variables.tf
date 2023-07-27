variable "environment" {
  description = "The name of the environment"
}
variable "aws_profile" {
  description = "The AWS-CLI profile for the account to create resources in."
}
variable "aws_region" {}
variable "project" {}
variable "key_name" {
  description = "Key for SSH"
}
variable "aws_ami_id" {}
variable "instance_type" {}
variable "bucket_name" {}

