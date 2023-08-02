output "codebuild_project_ids" {
  value = aws_codebuild_project.code-build[*].id
}