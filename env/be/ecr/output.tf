output "repo_uris" {
  value = aws_ecr_repository.ecr.*.repository_url
}
output "container_names" {
  value = aws_ecr_repository.ecr.*.name
}