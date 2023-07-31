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

resource "aws_security_group_rule" "outbound_ec2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2-ecs-sg.id
}

resource "aws_launch_template" "launch_config" {
  count         = length(local.cluster_names)
  name          = "${local.prefix_name}-lauch-template"
  image_id      = var.aws_ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    #    name = "${local.prefix_name}-iam-ec2-profile"
    arn = aws_iam_instance_profile.iam_profile.arn
  }

  key_name  = var.key_name
  user_data = base64encode(data.template_file.user_data[count.index].rendered)
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/cpu-options-supported-instances-values.html
  #  cpu_options {
  #    core_count       = 1
  #    threads_per_core = 2
  #  }
  credit_specification {
    cpu_credits = "standard"
  }
  disable_api_stop                     = false
  disable_api_termination              = false
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role-ec2" {
  name               = "${local.prefix_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.role-ec2.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}


resource "aws_iam_instance_profile" "iam_profile" {
  name = "${local.prefix_name}-ec2-profile"
  role = aws_iam_role.role-ec2.name
}

data "template_file" "user_data" {
  count    = length(local.cluster_names)
  template = file("${path.module}/templates/user_data.sh")

  vars = {
    name = local.cluster_names[count.index]
  }
}

resource "aws_autoscaling_group" "asg" {
  count             = length(local.cluster_names)
  name              = "${local.prefix_name}-asg"
  max_size          = 4
  min_size          = 1
  desired_capacity  = 1
  health_check_type = "EC2"
  launch_template {
    id      = aws_launch_template.launch_config[count.index].id
    version = aws_launch_template.launch_config[count.index].latest_version
  }
  #  launch_configuration      = aws_launch_template.launch_config.id
  vpc_zone_identifier       = data.terraform_remote_state.network.outputs.private_subnet_ids
  force_delete              = true
  health_check_grace_period = 300
  wait_for_capacity_timeout = 0
#  target_group_arns         = [data.terraform_remote_state.alb.outputs.target_group_arns[count.index]]
  protect_from_scale_in     = true
  tag {
    key                 = "AmazonECSManaged"
    propagate_at_launch = true
    value               = true
  }
}