resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags           = var.tags
}

locals {
  provider_arn = var.create_provider ? aws_iam_openid_connect_provider.this[0].arn : var.existing_provider_arn
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name                 = "${var.name}-${each.key}"
  max_session_duration = each.value.max_session_duration
  tags                 = var.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRoleWithWebIdentity"
      Principal = { Federated = local.provider_arn }
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = sort(tolist(each.value.subjects))
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "this" {
  for_each = var.roles

  name   = "deployment"
  role   = aws_iam_role.this[each.key].id
  policy = each.value.policy_json
}
