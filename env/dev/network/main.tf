locals {
  private_cidrs = slice(var.private_subnet_cidrs, 0, lookup(var.subnet_count, "private"))
  public_cidrs = slice(var.public_subnet_cidrs, 0, lookup(var.subnet_count, "public"))
  availability_zones = [for k in var.num_of_azs : "${var.aws_region}${k}"]
  prefix_name = "${var.project}-${var.environment}"
}

module "network" {
  source               = "../../../modules/network"
  availability_zones   = local.availability_zones
  environment          = var.environment
  private_subnet_cidrs = local.private_cidrs
  public_subnet_cidrs  = local.public_cidrs
  vpc_cidr             = var.vpc_cidr
  prefix_name          = local.prefix_name
}

#module "s3_bucket" {
#  source = "../../modules/s3"
#}
#
#module "alb" {
#  source = "../../modules/alb"
#
#  alb_name          = "haidm"
#  environment       = var.environment
#  public_subnet_ips = module.network.public_subnet_ids
#  vpc_id            = module.network.vpc_id
#  bucket_name       = module.s3_bucket.bucket_name
#}
#
#module "asg_template" {
#  source = "../../modules/asg_instances"
#
#  target_arn         = module.alb.target_arn
#  ami_id             = var.aws_ami_id
#  environment        = var.environment
#  instance_type      = var.instance_type
#  key_name           = var.key_name
#  private_subnet_ids = module.network.private_subnet_ids
#  vpc_id             = module.network.vpc_id
#  alb_sg_id          = module.alb.alb_sg_id
#  nat                = module.network.depend_nat
#}
#
#module "db" {
#  source = "../../modules/rds"
#
#  ec2_sg             = module.asg_template.ec2_sg
#  private_subnet_ids = module.network.private_subnet_ids
#  vpc_id             = module.network.vpc_id
#}