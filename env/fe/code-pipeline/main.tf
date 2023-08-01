locals {
  prefix_name = "${var.project}-${var.environment}"
}

resource "aws_codepipeline" "code-pipeline-node-js" {
  name     = "${local.prefix_name}-codepipeline-node-js"
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
        RepositoryName = "node-js"
        BranchName     = lookup(var.branch_match, var.environment)
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source-data"]
      version         = "1"
      output_artifacts = ["build-data"]
      configuration = {
        ProjectName = data.terraform_remote_state.fe-codebuild.outputs.code-build-node-js-name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["build-data"]
      version         = "1"
      region          = var.aws_region

      configuration = {
        BucketName = data.terraform_remote_state.fe-s3.outputs.bucket
        Extract = var.extract_when_deploy
      }
    }
  }
}