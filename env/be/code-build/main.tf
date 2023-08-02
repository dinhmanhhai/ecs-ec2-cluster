data "aws_caller_identity" "current" {}
locals {
  prefix_name = "${var.project}-${var.environment}"
  count       = length(data.terraform_remote_state.ecr.outputs.container_names)
}

resource "aws_codebuild_report_group" "code_build-report-group" {
  count = local.count
  name  = "${local.prefix_name}-report-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
  type  = "TEST"
  export_config {
    type = "NO_EXPORT"
  }
}

resource "aws_codebuild_project" "code-build" {
  count         = local.count
  name          = "${local.prefix_name}-codebuild-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
  description   = "${local.prefix_name}-codebuild"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.role_codebuild[count.index].arn
  badge_enabled = var.badge_enabled
  depends_on    = [aws_security_group.code_build_sg, aws_iam_role.role_codebuild]

  artifacts {
    type = var.artifacts_type
  }

  cache {
    type     = "S3"
    location = "${var.cache_bucket_name}/${local.prefix_name}-cache-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
    modes    = []
  }

  environment {
    privileged_mode             = var.privileged_mode
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    #    /* NOTE: not use yet */
    #    environment_variable {
    #      name  = "S3_BUCKET"
    #      value = data.terraform_remote_state.fe-s3.outputs.bucket
    #      #      type  = "PARAMETER_STORE"
    #    }
    dynamic "environment_variable" {
      for_each = lookup(var.env_vars, data.terraform_remote_state.ecr.outputs.container_names[count.index])
      content {
        name  = environment_variable.value["name"]
        value = environment_variable.value["value"]
        type  = environment_variable.value["type"]
      }
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = lookup(data.terraform_remote_state.repository.outputs.repo_map_uris, data.terraform_remote_state.ecr.outputs.container_names[count.index])
    git_clone_depth = 1
    buildspec       = data.local_file.buildspec_local[count.index].content

    git_submodules_config {
      fetch_submodules = true
    }
    insecure_ssl = var.insecure_ssl
  }

  source_version = "refs/heads/${lookup(var.branch_match, var.environment)}"

  vpc_config {
    vpc_id = data.terraform_remote_state.network.outputs.vpc_id

    subnets = data.terraform_remote_state.network.outputs.private_subnet_ids

    security_group_ids = [
      aws_security_group.code_build_sg.id
    ]
  }

  #  logs_config {
  #    cloudwatch_logs {
  #      group_name  = "log-group"
  #      stream_name = "log-stream"
  #    }
  #
  #    s3_logs {
  #      status   = "ENABLED"
  #      location = "${aws_s3_bucket.id}/build-log"
  #    }
  #  }
}

data "local_file" "buildspec_local" {
  count    = local.count
  filename = "${path.module}/templates/${data.terraform_remote_state.ecr.outputs.container_names[count.index]}-buildspec.yml"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role_codebuild" {
  count              = local.count
  name               = "${local.prefix_name}-codebuild-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  count      = local.count
  role       = aws_iam_role.role_codebuild[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  count      = local.count
  role       = aws_iam_role.role_codebuild[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

#resource "aws_iam_role_policy_attachment" "ec2-ecr_policy" {
#  role       = aws_iam_role.role_codebuild.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
#}

####### Base Cache policy
resource "aws_iam_role_policy" "base_cache_codebuild" {
  count  = local.count
  policy = data.template_file.base_cache_policy.rendered
  role   = aws_iam_role.role_codebuild[count.index].id
}

data "template_file" "base_cache_policy" {
  template = file("${path.module}/templates/cache-policy.json")

  vars = {
    cache_bucket = var.cache_bucket_name
  }
}

####### Base build policy
resource "aws_iam_role_policy" "base_build_codebuild" {
  count  = local.count
  policy = data.template_file.base_build_policy[count.index].rendered
  role   = aws_iam_role.role_codebuild[count.index].id
}

data "template_file" "base_build_policy" {
  count    = local.count
  template = file("${path.module}/templates/base-policy.json")

  vars = {
    codebuild-name = "${local.prefix_name}-codebuild-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
    cache_bucket   = var.cache_bucket_name
    repo_arn       = lookup(data.terraform_remote_state.repository.outputs.repo_arns, data.terraform_remote_state.ecr.outputs.container_names[count.index])
    report_group   = aws_codebuild_report_group.code_build-report-group[count.index].arn
  }
}

####### Base vpc policy
resource "aws_iam_role_policy" "base_vpc_codebuild" {
  count  = local.count
  policy = data.template_file.base_vpc_policy.rendered
  role   = aws_iam_role.role_codebuild[count.index].id
}

data "template_file" "base_vpc_policy" {
  template = file("${path.module}/templates/vpc-policy.json")

  vars = {
    private_subnet_arns = jsonencode(data.terraform_remote_state.network.outputs.private_subnet_arns)
    region              = var.aws_region
    account_id          = data.aws_caller_identity.current.account_id
  }
}

# Code build security
resource "aws_security_group" "code_build_sg" {
  name   = "${local.prefix_name}-codebuild-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}