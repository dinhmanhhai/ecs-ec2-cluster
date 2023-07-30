output "target_group_arns" {
  value = aws_alb_target_group.target_group.*.arn
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "alb_id" {
  value = aws_alb.alb.id
}
output "alb_arn" {
  value = aws_alb.alb.arn
}
output "target_group" {
  value = aws_alb_target_group.target_group
}