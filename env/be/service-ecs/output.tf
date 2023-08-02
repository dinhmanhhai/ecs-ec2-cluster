output "service_ids" {
  value = aws_ecs_service.worker[*].id
}
output "service_names" {
  value = aws_ecs_service.worker[*].name
}