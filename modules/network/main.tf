module "vpc" {
  source = "./vpc"

  cidr        = var.vpc_cidr
  environment = var.environment
}

module "private_subnet" {
  source = "./subnet"

  name               = "${var.prefix_name}_private_subnet"
  environment        = var.environment
  vpc_id             = module.vpc.id
  cidrs              = var.private_subnet_cidrs
  availability_zones = var.availability_zones
}

module "public_subnet" {
  source = "./subnet"

  name               = "${var.prefix_name}_public_subnet"
  environment        = var.environment
  vpc_id             = module.vpc.id
  cidrs              = var.public_subnet_cidrs
  availability_zones = var.availability_zones
}

module "nat" {
  source = "./nat_gateway"

  subnet_ids   = module.public_subnet.ids
  subnet_count = var.create_nat ? length(var.availability_zones) : 0
  environment  = var.environment
}

resource "aws_route" "public_igw_route" {
  count                  = length(var.public_subnet_cidrs)
  route_table_id         = element(module.public_subnet.route_table_ids, count.index)
  gateway_id             = module.vpc.igw
  destination_cidr_block = var.destination_cidr_block
}

resource "aws_route" "private_nat_route" {
  count                  = var.create_nat ? length(var.private_subnet_cidrs) : 0
  route_table_id         = element(module.private_subnet.route_table_ids, count.index)
  nat_gateway_id         = element(module.nat.ids, count.index)
  destination_cidr_block = var.destination_cidr_block
}
