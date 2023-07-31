locals {
  prefix_name = "${var.project}-${var.environment}"
  cluster_names = [for k in var.cluster_names : "${local.prefix_name}-${k}-cluster"]
}
#
#resource "aws_ecs_cluster" "aws-ecs-cluster" {
#  count                = length(local.cluster_names)
#  name                 = element(local.cluster_names, count.index)
##  configuration {
##    execute_command_configuration {
##      log_configuration {
##
##      }
##    }
##  }
#}
#
#resource "aws_ecs_capacity_provider" "ec2-ecs-provider" {
#  count = length(local.cluster_names)
#  name = local.cluster_names[count.index]
#
#
#  auto_scaling_group_provider {
##    managed_termination_protection = "ENABLED"
#    auto_scaling_group_arn = data.terraform_remote_state.asg.outputs.asg_arns[count.index]
#  }
#}
##
#resource "aws_ecs_cluster_capacity_providers" "example" {
#  cluster_name = aws_ecs_cluster.aws-ecs-cluster[0].name
#
#
##  capacity_providers = ["FARGATE", "EC2"]
##
##  default_capacity_provider_strategy {
##    base              = 1
##    weight            = 100
##    capacity_provider = "FARGATE"
##  }
#}

#################################################################################

module "ecs" {
  count = length(local.cluster_names)
#  source = "terraform-aws-modules/ecs/aws"
  source = "../../../modules/ecs"

  cluster_name = element(local.cluster_names, count.index)

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  autoscaling_capacity_providers = {
    one = {
      auto_scaling_group_arn         = data.terraform_remote_state.asg.outputs.asg_arns[count.index]
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 5
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 1
      }

      default_capacity_provider_strategy = {
        weight = 100
        base   = 0
      }
    }
#    two = {
#      auto_scaling_group_arn         = data.terraform_remote_state.asg.outputs.asg_arns[count.index]
#      managed_termination_protection = "ENABLED"
#
#      managed_scaling = {
#        maximum_scaling_step_size = 15
#        minimum_scaling_step_size = 5
#        status                    = "ENABLED"
#        target_capacity           = 90
#      }
#
#      default_capacity_provider_strategy = {
#        weight = 40
#      }
#    }
  }
  autoscaling_min_capacity = data.terraform_remote_state.asg.outputs.autoscaling_min_capacity[count.index]
  autoscaling_max_capacity = data.terraform_remote_state.asg.outputs.autoscaling_max_capacity[count.index]
#  tags = {
#    Environment = "Development"
#    Project     = "EcsEc2"
#  }
}