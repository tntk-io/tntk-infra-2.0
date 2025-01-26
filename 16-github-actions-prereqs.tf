# This resource creates the GitHub Actions secrets and variables required for our GitHub Actions workflow
locals {
  # Common variables and secrets that all repositories share
  base_variables = {
    ACCOUNT_ID            = var.aws_account_id
    AWS_REGION            = var.aws_region
    BASE_DOMAIN           = var.base_domain
    APPLICATION_NAMESPACE = "application"
    ENVIRONMENT           = var.tag_env
    CD_DESTINATION_OWNER  = var.github_organization
    CD_PROJECT            = "tntk-cd"
    GH_EMAIL              = var.github_email
    GH_NAME               = var.github_name
    GHA_ECR_ROLE_ARN      = aws_iam_role.github_actions_ecr.arn
  }

  base_secrets = {
    API_TOKEN_GITHUB = var.github_token
  }

  repo_variables = [
    "YQ_PATH",
    "APPLICATION_NAME",
  ]

  # List of repositories
  repositories = [
    "tntk-web",
    "tntk-orders",
    "tntk-products",
    "tntk-auth"
  ]

  # Create flattened maps for variables and secrets
  all_variables = merge([
    for repo in local.repositories : {
      for var_name, var_value in local.base_variables : "${repo}/${var_name}" => {
        repository = repo
        name       = var_name
        value      = var_value
      }
    }
  ]...)

  all_secrets = merge([
    for repo in local.repositories : {
      for secret_name, secret_value in local.base_secrets : "${repo}/${secret_name}" => {
        repository = repo
        name       = secret_name
        value      = secret_value
      }
    }
  ]...)

  # Dynamic variables that are specific to each repository
  # Maps each repository to its corresponding camel case value for YQ_PATH
  dynamic_variables = {
    for pair in flatten([
      for repo in local.repositories : [
        for variable in local.repo_variables : {
          key        = "${repo}/${variable}"
          repository = repo
          name       = variable
          value      = variable == "APPLICATION_NAME" ? "${var.tag_env}/${repo}" : repo
        }
      ]
    ]) : pair.key => pair
  }
}

resource "github_actions_variable" "variable" {
  for_each = local.all_variables

  repository    = each.value.repository
  variable_name = each.value.name
  value         = each.value.value

  depends_on = [github_repository.repos]
}

resource "github_actions_variable" "dynamic_variable" {
  for_each = {
    for key, value in local.dynamic_variables : key => value
    if value.repository != null
  }

  repository    = each.value.repository
  variable_name = each.value.name
  value         = each.value.value

  depends_on = [github_repository.repos]
}

resource "github_actions_secret" "secret" {
  for_each = local.all_secrets

  repository      = each.value.repository
  secret_name     = each.value.name
  plaintext_value = each.value.value

  depends_on = [github_repository.repos]
}
