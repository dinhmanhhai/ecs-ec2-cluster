resource "aws_security_group" "alb_sg" {
  name        = "${var.environment}_alb_sg"
  description = "Used in ${var.environment}"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "https_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "outbound_internet_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}


resource "aws_alb" "alb" {
  name = var.alb_name
  subnets = var.public_subnet_ips
  internal = false
  enable_cross_zone_load_balancing = true
  security_groups = [aws_security_group.alb_sg.id]

  access_logs {
    bucket = var.bucket_name
    enabled = var.bucket_name != "" ? true : false
  }
}

resource "aws_alb_target_group" "target_group" {

  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    path     = var.health_check_path
    protocol = "HTTP"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.id
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.target_group.id
  }
}