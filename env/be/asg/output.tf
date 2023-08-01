output "asg_arns" {
  value = aws_autoscaling_group.asg.*.arn
}
output "autoscaling_min_capacity" {
  value = aws_autoscaling_group.asg[*].min_size
}
output "autoscaling_max_capacity" {
  value = aws_autoscaling_group.asg[*].max_size
}
output "task_sg_id" {
  value = aws_security_group.ec2-ecs-sg.id
}