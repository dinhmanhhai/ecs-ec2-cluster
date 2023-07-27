variable "vpc_id" {}
variable "ec2_sg" {}
variable "private_subnet_ids" {}
variable "settings" {
  description = "Configuration settings"
  type = map(any)
  default = {
    "database" = {
      allocated_storage = 10
      engine = "mysql"
      instance_class = "db.t2.micro"
      db_name = "haidm_rds"
      skip_final_snapshot = true
    }
  }
}

variable "db_username" {
  description = "DB master user"
  type = string
  sensitive = true
  default = "admin"
}

variable "db_password" {
  description = "DB password master user"
  type = string
  default = "Camvaonikbomay2"
}
