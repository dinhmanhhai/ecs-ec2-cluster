output "repo_ids" {
  value = aws_codecommit_repository.repo.*.id
}
output "repo_map_uris" {
  value = tomap({
    for i, id in aws_codecommit_repository.repo.*.id :
    id => aws_codecommit_repository.repo.*.clone_url_http[i]
  })
}
output "repo_arns" {
  value = tomap({
    for i, id in aws_codecommit_repository.repo.*.id :
    id => aws_codecommit_repository.repo.*.arn[i]
  })
}