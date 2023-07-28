locals {
  prefix_name = "${var.project}-${var.environment}"
  cluster_names = [for k in var.cluster_names : "${local.prefix_name}-${k}-cluster"]
}

resource "aws_ecs_cluster" "aws-ecs-cluster" {
  count                = length(local.cluster_names)
  name                 = element(local.cluster_names, count.index)
}