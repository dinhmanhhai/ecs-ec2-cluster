output "codepipeline_arns" {
  value = tomap({
    for i, id in data.terraform_remote_state.ecr.outputs.container_names :
    id => aws_codepipeline.code_pipeline-ecs[i].arn
  })
}