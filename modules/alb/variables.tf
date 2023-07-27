variable "alb_name" {}
variable "public_subnet_ips" {}
variable "environment" {}
variable "vpc_id" {}
variable "bucket_name" {}
variable "deregistration_delay" {
  default     = "300"
}
variable "health_check_path" {
  default     = "/"
}