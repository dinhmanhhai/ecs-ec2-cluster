resource "aws_security_group" "ec2-sg" {
  name        = "${var.environment}_ec2_sg"
  description = "Used in ${var.environment}"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "inbound_ec2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "TCP"
  source_security_group_id = var.alb_sg_id
  security_group_id        = aws_security_group.ec2-sg.id
}

resource "aws_launch_configuration" "launch_config" {
  image_id        = var.ami_id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ec2-sg.id]
  key_name        = var.key_name
  user_data       = data.template_file.user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  max_size             = 4
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.launch_config.id
  vpc_zone_identifier  = var.private_subnet_ids
  force_delete         = true
  target_group_arns    = [var.target_arn]

  depends_on = [var.nat]
}

data "template_file" "user_data" {
  template = file("${path.module}/templates/user_data.sh")
}