locals {
  prefix_name = "${var.project}-${var.environment}"
}
resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = data.terraform_remote_state.ecs.outputs.cluster_ids[0]
  task_definition = data.terraform_remote_state.task.outputs.task_ids[0]
  desired_count   = 2
  network_configuration {
    assign_public_ip = var.assign_public_ip_for_tasks
    subnets = data.terraform_remote_state.network.outputs.private_subnet_ids
#    security_groups {}

  }
}