output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}
output "depend_nat" {
  value = module.network.depend_nat
}
output "nat_ids" {
  value = module.network.nat_ids
}
output "vpc_cidr" {
  value = module.network.vpc_cidr
}
output "vpc_id" {
  value = module.network.vpc_id
}