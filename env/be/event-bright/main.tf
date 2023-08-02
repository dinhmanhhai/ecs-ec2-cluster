locals {
  create_public_repository_values = {
    "prod" : false,
    "dev" : true,
    "stg" : true,
  }
  create_public_repository = lookup(local.create_public_repository_values, var.environment)
  force_delete             = lookup(local.create_public_repository_values, var.environment)
}

resource "aws_ecr_repository" "ecr" {
  count                = length(var.ecr_names)
  name                 = element(var.ecr_names, count.index)
  force_delete         = local.force_delete
  image_tag_mutability = var.image_mutability
  encryption_configuration {
    encryption_type = var.encryption_type
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  count      = length(var.ecr_names)
  repository = aws_ecr_repository.ecr[count.index].name

  policy = data.template_file.ecr_policy[count.index].rendered
}

data "template_file" "ecr_policy" {
  count    = length(var.ecr_names)
  template = file("${path.module}/templates/ecr_policy.json")

  vars = {
    environment = var.environment
  }
}