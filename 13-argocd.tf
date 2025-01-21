resource "aws_ssm_parameter" "ssm_argocd_admin_password" {
  name  = "/argocd/admin/password"
  type  = "SecureString"
  value = data.kubernetes_secret.argocd_admin_password.data["password"]
}

resource "github_repository_file" "values_yaml" {
  repository = github_repository.repos["tntk-cd"].name
  file       = "environments/${var.tag_env}/values.yaml"
  content = templatefile(".devops/helm/tntk-bookapp.yaml", {
    ENVIRONMENT           = var.tag_env
    ECR_REPO_WEB          = module.ecr["${var.tag_env}/tntk-web"].repository_url
    ECR_REPO_ORDERS       = module.ecr["${var.tag_env}/tntk-orders"].repository_url
    ECR_REPO_AUTH         = module.ecr["${var.tag_env}/tntk-auth"].repository_url
    ECR_REPO_PRODUCTS     = module.ecr["${var.tag_env}/tntk-products"].repository_url
    TNTK_WEB_INGRESS_HOST = "tntk-bookapp.${var.base_domain}"
  })
}

resource "argocd_repository_credentials" "github" {
  url      = "https://github.com/${var.github_organization}"
  username = "git"
  password = var.github_token

  depends_on = [module.eks, module.eks_addons]
}

resource "argocd_repository" "repos" {
  for_each = var.argocd_repos

  name = each.key
  repo = each.value["repo_url"]
  type = "git"

  depends_on = [module.eks, module.eks_addons]
}

resource "argocd_application" "argocd_application" {
  for_each = var.argocd_apps
  metadata {
    name      = each.value["name"]
    namespace = each.value["namespace"]
  }
  cascade = false
  wait    = true
  spec {
    project = "default"
    destination {
      server    = each.value["destination"]["server"]
      namespace = each.value["destination"]["namespace"]
    }

    source {
      repo_url        = each.value["source"]["repo_url"]
      path            = each.value["source"]["chart"]
      target_revision = "HEAD"

      helm {
        value_files = each.value["helm"]["value_files_path"]
      }
    }


    sync_policy {
      automated {
        prune     = true
        self_heal = true
      }
    }
  }
  depends_on = [module.eks, module.eks_addons, argocd_repository.repos]
}
