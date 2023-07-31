locals {
  prefix_name = "${var.project}-${var.environment}"

  # ? khong viet truc tiep duoc vao container_definitions
  port = tonumber(lookup(var.container_port_mapping, data.terraform_remote_state.ecr.outputs.container_names[1]))
}

resource "aws_ecs_task_definition" "aws-ecs-task" {
  count = length(data.terraform_remote_state.ecr.outputs.container_names)

  family                   = "${local.prefix_name}-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
  requires_compatibilities = ["EC2"] #["FARGATE"]
  network_mode             = "bridge"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = data.terraform_remote_state.iam.outputs.arn
  task_role_arn            = data.terraform_remote_state.iam.outputs.arn
  container_definitions    = data.template_file.ecr_policy[count.index].rendered
}

data "template_file" "ecr_policy" {
  count    = length(data.terraform_remote_state.ecr.outputs.container_names)
  template = file("container_definitions.json")

  vars = {
    name                  = "${data.terraform_remote_state.ecr.outputs.container_names[count.index]}-container",
    image                 = "${data.terraform_remote_state.ecr.outputs.repo_uris[count.index]}:latest",
    awslogs-group         = data.terraform_remote_state.cloudwatch.outputs.ids[count.index],
    awslogs-region        = var.aws_region,
    networkMode           = "bridge",
    awslogs-stream-prefix = "${local.prefix_name}-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
    port                  = tonumber(lookup(var.container_port_mapping, data.terraform_remote_state.ecr.outputs.container_names[count.index]))
  }
}
#data "aws_ecs_task_definition" "main" {
#  count = length(data.terraform_remote_state.ecr.outputs.container_names)
#  task_definition = aws_ecs_task_definition.aws-ecs-task.family[count.index]
#}