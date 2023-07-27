output "ids" {
  value = aws_nat_gateway.nat.*.id
}
output "depend_nat" {
  value = aws_nat_gateway.nat
}
