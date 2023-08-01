output "task_ids" {
  value = aws_ecs_task_definition.aws-ecs-task[*].id
}
output "container_names" {
  value = [for k in data.terraform_remote_state.ecr.outputs.container_names : k]
}