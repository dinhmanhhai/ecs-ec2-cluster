locals {
  prefix_name = "${var.project}-${var.environment}"
  count       = length(data.terraform_remote_state.ecr.outputs.container_names)
}
resource "aws_cloudwatch_event_rule" "codecommit_activity" {
  count       = local.count
  name_prefix = "${local.prefix_name}-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}-activity"

  event_pattern = data.template_file.event_pattern[count.index].rendered
}

data "template_file" "event_pattern" {
  count    = local.count
  template = file("${path.module}/templates/event-pattern.json")

  vars = {
    repo_arn = lookup(data.terraform_remote_state.repository.outputs.repo_arns, data.terraform_remote_state.ecr.outputs.container_names[count.index])
    branch   = lookup(var.branch_match, var.environment)
  }
}

resource "aws_cloudwatch_event_target" "cloudwatch_triggers_pipeline" {
  count     = local.count
  target_id = "${local.prefix_name}-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}-target-id"
  rule      = aws_cloudwatch_event_rule.codecommit_activity[count.index].name
  arn       = lookup(data.terraform_remote_state.codepipeline_ecs.outputs.codepipeline_arns, data.terraform_remote_state.ecr.outputs.container_names[count.index])
  role_arn  = aws_iam_role.cloudwatch_ci_role[count.index].arn
}

resource "aws_iam_role" "cloudwatch_ci_role" {
  count              = local.count
  name               = "${local.prefix_name}-cwe-ci-${data.terraform_remote_state.ecr.outputs.container_names[count.index]}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

####### Trigger policy
resource "aws_iam_role_policy" "trigger_pipeline" {
  count  = local.count
  policy = data.template_file.trigger_policy[count.index].rendered
  role   = aws_iam_role.cloudwatch_ci_role[count.index].id
}

data "template_file" "trigger_policy" {
  count = local.count
  template = file("${path.module}/templates/trigger-pipeline.json")

  vars = {
    pipeline_arn = lookup(data.terraform_remote_state.codepipeline_ecs.outputs.codepipeline_arns, data.terraform_remote_state.ecr.outputs.container_names[count.index])
  }
}