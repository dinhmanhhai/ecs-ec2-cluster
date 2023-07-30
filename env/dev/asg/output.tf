output "asg_arns" {
  value = aws_autoscaling_group.asg.*.arn
}