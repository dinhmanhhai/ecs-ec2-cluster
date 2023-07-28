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
  template = file("ecr_policy.json")

  vars = {
    environment = var.environment
  }
}

#resource "aws_ecrpublic_repository" "this" {
#  count = local.create_public_repository ? length(var.ecr_names) : 0
#
#  repository_name = element(var.ecr_names, count.index)
#
#  #  dynamic "catalog_data" {
#  #    for_each = length(var.public_repository_catalog_data) > 0 ? [var.public_repository_catalog_data] : []
#  #
#  #    content {
#  #      about_text        = try(catalog_data.value.about_text, null)
#  #      architectures     = try(catalog_data.value.architectures, null)
#  #      description       = try(catalog_data.value.description, null)
#  #      logo_image_blob   = try(catalog_data.value.logo_image_blob, null)
#  #      operating_systems = try(catalog_data.value.operating_systems, null)
#  #      usage_text        = try(catalog_data.value.usage_text, null)
#  #    }
#  #  }
#}