variable "name" {
  description = "Name of the subnet, actual name will be, for example: name_eu-west-1a"
}

variable "environment" {
  description = "The name of the environment"
}

variable "cidrs" {
  type = list(any)
}

variable "availability_zones" {
  type = list(any)
}

variable "vpc_id" {
}