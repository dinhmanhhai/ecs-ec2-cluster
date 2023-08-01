locals {
  prefix_name = "${var.project}-${var.environment}"
}
resource "aws_ecs_service" "worker" {
  count           = length(data.terraform_remote_state.task.outputs.task_ids)
  name            = "worker-${count.index}"
  cluster         = data.terraform_remote_state.ecs.outputs.cluster_ids[0]
  task_definition = data.terraform_remote_state.task.outputs.task_ids[count.index]
  desired_count   = 2
  network_configuration {
    assign_public_ip = var.assign_public_ip_for_tasks
    subnets          = data.terraform_remote_state.network.outputs.private_subnet_ids
    security_groups  = [data.terraform_remote_state.asg.outputs.task_sg_id]
  }
  load_balancer {
    target_group_arn = data.terraform_remote_state.alb.outputs.target_group_arns[count.index]
    container_name   = data.terraform_remote_state.task.outputs.container_names[count.index]
    container_port   = tonumber(lookup(var.container_port_mapping, data.terraform_remote_state.task.outputs.container_names[count.index]))
  }
}