locals {
  prefix_name = "${var.project}-${var.environment}"
}

resource "aws_cloudwatch_log_group" "log-group" {
  count = length(data.terraform_remote_state.ecr.outputs.container_names)
  name = "${local.prefix_name}-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}-watch-logs"
}