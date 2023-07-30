locals {
  prefix_name   = "${var.project}-${var.environment}"
  cluster_names = [for k in var.cluster_names : "${local.prefix_name}-${k}-cluster"]
}


resource "aws_security_group" "ec2-ecs-sg" {
  name   = "${local.prefix_name}-ec2-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_security_group_rule" "inbound_ec2" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = data.terraform_remote_state.alb.outputs.alb_sg_id
  security_group_id        = aws_security_group.ec2-ecs-sg.id
}

resource "aws_launch_template" "launch_config" {
  count = length(local.cluster_names)
  name          = "${local.prefix_name}-lauch-template"
  image_id      = var.aws_ami_id
  instance_type = var.instance_type
  #  vpc_security_group_ids = [aws_security_group.ec2-ecs-sg.id]
  key_name  = var.key_name
  user_data = base64encode(data.template_file.user_data[count.index].rendered)
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  credit_specification {
    cpu_credits = "standard"
  }
  disable_api_stop                     = true
  disable_api_termination              = true
  ebs_optimized                        = true
  instance_initiated_shutdown_behavior = "terminate"
#  instance_market_options {
#    market_type = "spot"
#  }
  network_interfaces {
    security_groups             = [aws_security_group.ec2-ecs-sg.id]
    associate_public_ip_address = false
  }

}

data "template_file" "user_data" {
  count = length(local.cluster_names)
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    name = local.cluster_names[count.index]
  }
}

resource "aws_autoscaling_group" "asg" {
  count = length(local.cluster_names)
  name             = "${local.prefix_name}-asg"
  max_size         = 4
  min_size         = 0
  desired_capacity = 0
  launch_template {
    id      = aws_launch_template.launch_config[count.index].id
    version = aws_launch_template.launch_config[count.index].latest_version
    #    name = aws_launch_template.launch_config.name
  }
  #  launch_configuration      = aws_launch_template.launch_config.id
  vpc_zone_identifier       = data.terraform_remote_state.network.outputs.private_subnet_ids
  force_delete              = true
  health_check_grace_period = 300
  wait_for_capacity_timeout = 0
  #  target_group_arns = data.terraform_remote_state.alb.outputs.target_group_arns

  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
}