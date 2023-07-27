resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id
  name = "rds_sg"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [var.ec2_sg]
  }
}

resource "aws_db_subnet_group" "rds_subnet" {
  name = "rds_subnet"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "rds_instance" {
  instance_class = var.settings.database.instance_class
  db_name = var.settings.database.db_name
  allocated_storage = var.settings.database.allocated_storage
  apply_immediately = true
  username = var.db_username
  password = var.db_password
  #  engine_version = var.settings.database.engine_version
  engine = var.settings.database.engine
  backup_retention_period = 7
  allow_major_version_upgrade = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.id
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = var.settings.database.skip_final_snapshot
}