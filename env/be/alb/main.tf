locals {
  prefix_name = "${var.project}-${var.environment}"
  port_listener = [80, 443]

}
resource "aws_security_group" "alb_sg" {
  name        = "${local.prefix_name}-alb-sg"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
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
  name = "${local.prefix_name}-alb"
  subnets = data.terraform_remote_state.network.outputs.public_subnet_ids
  internal = false
  enable_cross_zone_load_balancing = true
  security_groups = [aws_security_group.alb_sg.id]

#  access_logs {
#    bucket = var.bucket_name
#    enabled = var.bucket_name != "" && var.bucket_name != null ? true : false
#  }
}

resource "aws_alb_target_group" "target_group" {
  count = length(data.terraform_remote_state.ecr.outputs.container_names)
  name = "${local.prefix_name}-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}-target-group"
  port = tonumber(lookup(var.container_port_mapping, data.terraform_remote_state.ecr.outputs.container_names[count.index]))
  protocol = "HTTP"
  target_type = var.target_type
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http-and-https" {
  count = 2
  load_balancer_arn = aws_alb.alb.id
  port = local.port_listener[count.index]
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "NOT FOUND"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "http-forward" {
  count = length(data.terraform_remote_state.ecr.outputs.container_names)
  listener_arn = aws_alb_listener.http-and-https[0].arn
  priority     = count.index + 1

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group[count.index].arn
  }

  condition {
    path_pattern {
      values = [lookup(var.path_mapping, data.terraform_remote_state.ecr.outputs.container_names[count.index])]
    }
  }

#  condition {
#    host_header {
#      values = ["example.com"]
#    }
#  }
}

#data "aws_route53_zone" "domain" {
#  name         = "${var.domain_name}."
#  private_zone = "${var.private_zone}"
#}
#
#resource "aws_route53_record" "hostname" {
#  zone_id = "${data.aws_route53_zone.domain.zone_id}"
#  name    = "${var.host_name != "" ? format("%s.%s", var.host_name, data.aws_route53_zone.domain.name) : format("%s", data.aws_route53_zone.domain.name)}"
#  type    = "A"
#
#  alias {
#    name                   = "${module.alb.alb_dns_name}"
#    zone_id                = "${module.alb.alb_zone_id}"
#    evaluate_target_health = true
#  }
#}
