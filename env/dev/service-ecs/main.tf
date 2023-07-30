locals {
  prefix_name = "${var.project}-${var.environment}"
}
#resource "aws_ecs_service" "worker" {
#  name            = "worker"
#  cluster         = aws_ecs_cluster.ecs_cluster.id
#  task_definition = aws_ecs_task_definition.task_definition.arn
#  desired_count   = 2
#}