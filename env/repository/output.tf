output "repo_ids" {
  value = aws_codecommit_repository.repo.*.id
}