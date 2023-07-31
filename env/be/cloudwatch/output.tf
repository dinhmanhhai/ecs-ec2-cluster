output "ids" {
  value = aws_cloudwatch_log_group.log-group.*.id
}