output "task_ids" {
  value = aws_ecs_task_definition.aws-ecs-task[*].id
}