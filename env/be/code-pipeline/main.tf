locals {
  prefix_name = "${var.project}-${var.environment}"
  count       = length(data.terraform_remote_state.ecr.outputs.container_names)
}

resource "aws_codepipeline" "code_pipeline-ecs" {
  count    = local.count
  name     = "${local.prefix_name}-codepipeline-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
  role_arn = "arn:aws:iam::400516100932:role/service-role/AWSCodePipelineServiceRole-us-east-1-angular"


  artifact_store {
    location = "codepipeline-us-east-1-592600109059"
    type     = "S3"
    /* NOTE: not yet */
    #      encryption_key {
    #        id   = data.aws_kms_alias.s3kmskey.arn
    #        type = "KMS"
    #      }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source-data"]

      configuration = {
        PollForSourceChanges = false
        OutputArtifactFormat = "CODE_ZIP"
        RepositoryName       = data.terraform_remote_state.ecr.outputs.container_names[count.index]
        BranchName           = lookup(var.branch_match, var.environment)
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source-data"]
      version          = "1"
      output_artifacts = ["build-data"]
      configuration = {
        ProjectName = data.terraform_remote_state.codebuild-ecs.outputs.codebuild_project_ids[count.index]
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build-data"]
      version         = "1"
      region          = var.aws_region

      configuration = lookup(var.stage_deploy_configure, data.terraform_remote_state.ecr.outputs.container_names[count.index])
    }
  }
}