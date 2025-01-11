# This resource creates the GitHub Actions secrets and variables required for our GitHub Actions workflow
locals {
  camel_case_variables = {
    final-project-web = "tntkWeb"
    final-project-orders = "tntkOrders"
    final-project-products = "tntkBooks"
    final-project-auth = "tntkAuth"
  }

  # Common variables and secrets that all repositories share
  base_variables = {
    ACCOUNT_ID                  = var.aws_account_id
    AWS_REGION                  = var.aws_region
    BASE_DOMAIN                 = var.base_domain
    APPLICATION_NAME            = "demoapp"
    APPLICATION_NAMESPACE       = "application"
    CD_DESTINATION_OWNER        = var.github_organization
    CD_PROJECT                  = "final-project-cd"
    GITHUB_EMAIL                = var.github_email
    GITHUB_NAME                 = var.github_name
    GITHUB_ACTIONS_ECR_ROLE_ARN = aws_iam_role.github_actions_ecr.arn
  }

  base_secrets = {
    API_TOKEN_GITHUB = base64encode(var.github_token)
  }

  # Dynamic variables that are specific to each repository
  # If repo == camel_case_variables, then we use the camel_case_variables value as the YQ_TAG_PATH
  dynamic_variables = {
    for repo in local.repositories : repo => {
      for var_name, var_value in local.camel_case_variables : "${repo}/${var_name}" => {
        repository = "${var.github_organization}/${repo}"
        name       = "YQ_TAG_PATH"
        value      = var_value
      } if var_name == repo
    }
  }

  # List of repositories
  repositories = [
    "final-project-web",
    "final-project-orders",
    "final-project-products",
    "final-project-auth"
  ]

  # Create flattened maps for variables and secrets
  all_variables = merge([
    for repo in local.repositories : {
      for var_name, var_value in local.base_variables : "${repo}/${var_name}" => {
        repository = "${var.github_organization}/${repo}"
        name       = var_name
        value      = var_value
      }
    }
  ]...)



  all_secrets = merge([
    for repo in local.repositories : {
      for secret_name, secret_value in local.base_secrets : "${repo}/${secret_name}" => {
        repository = "${var.github_organization}/${repo}"
        name       = secret_name
        value      = secret_value
      }
    }
  ]...)
}

resource "github_actions_variable" "variable" {
  for_each = local.all_variables

  repository    = each.value.repository
  variable_name = each.value.name
  value         = each.value.value

  depends_on = [github_repository.repos]
}

resource "github_actions_variable" "dynamic_variable" {
  for_each = local.dynamic_variables

  repository    = each.value.repository
  variable_name = each.value.name
  value         = each.value.value

  depends_on = [github_repository.repos]
}

resource "github_actions_secret" "secret" {
  for_each = local.all_secrets

  repository      = each.value.repository
  secret_name     = each.value.name
  encrypted_value = each.value.value

  depends_on = [github_repository.repos]
}