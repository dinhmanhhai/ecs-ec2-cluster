locals {
#  prefix_name = "${var.project}-${var.environment}"
  repos = ["spring-app-terraform"]
}

resource "aws_codecommit_repository" "repo" {
  count = length(local.repos)
  repository_name = local.repos[count.index]
  default_branch = "master"
}