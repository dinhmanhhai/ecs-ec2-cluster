locals {
  prefix_name = "${var.project}-${var.environment}"
}

resource "aws_codebuild_report_group" "code_build-report-group" {
  name = "${local.prefix_name}-report"
  type = "TEST"
  export_config {
    type = "NO_EXPORT"
  }
}

resource "aws_codebuild_project" "code-build" {
  name          = "${local.prefix_name}-codebuild-node-js"
  description   = "${local.prefix_name}-codebuild"
  build_timeout = var.build_timeout
  service_role  = aws_iam_role.role-codebuild.arn
  badge_enabled = var.badge_enabled

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${var.bucket_name}/${local.prefix_name}-build-cache"
    modes    = []
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    /* NOTE: not yet */
    environment_variable {
      name  = "S3_BUCKET"
      value = data.terraform_remote_state.fe-s3.outputs.bucket
      #      type  = "PARAMETER_STORE"
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = lookup(data.terraform_remote_state.repository.outputs.repo_map_uris, "node-js")
    git_clone_depth = 1
    buildspec       = data.local_file.buildspec_local.content

    git_submodules_config {
      fetch_submodules = true
    }
    insecure_ssl = var.insecure_ssl
  }

  source_version = lookup(var.branch_match, var.environment)

  #  vpc_config {
  #    vpc_id = aws_vpc.example.id
  #
  #    subnets = [
  #      aws_subnet.example1.id,
  #      aws_subnet.example2.id,
  #    ]
  #
  #    security_group_ids = [
  #      aws_security_group.example1.id,
  #      aws_security_group.example2.id,
  #    ]
  #  }

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
  filename = "${path.module}/templates/buildspec.yml"
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

resource "aws_iam_role" "role-codebuild" {
  name               = "${local.prefix_name}-codebuild-node-js-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.role-codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

####### Base Cache
resource "aws_iam_role_policy" "base-cache-codebuild" {
  policy = data.template_file.base_cache_policy.rendered
  role   = aws_iam_role.role-codebuild.id
}

data "template_file" "base_cache_policy" {
  template = file("${path.module}/templates/cache-policy.json")

  vars = {
    cache_bucket = var.cache_bucket_name
  }
}

####### Base build
resource "aws_iam_role_policy" "base-build-codebuild" {
  policy = data.template_file.base_build_policy.rendered
  role   = aws_iam_role.role-codebuild.id
}

data "template_file" "base_build_policy" {
  template = file("${path.module}/templates/build-policy.json")

  vars = {
    codebuild-name = aws_codebuild_project.code-build.name
    cache_bucket   = var.cache_bucket_name
    repo_arn       = lookup(data.terraform_remote_state.repository.outputs.repo_arns, "node-js")
    report_group   = aws_codebuild_report_group.code_build-report-group.arn
  }
}
