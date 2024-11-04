resource "aws_ssm_parameter" "ssm_argocd_admin_password" {
  name  = "/argocd/admin/password"
  type  = "SecureString"
  value = data.kubernetes_secret.argocd_admin_password.data["password"]
}

resource "kubernetes_secret" "argocd_git_creds" {
  metadata {
    namespace = "argocd"
    name      = "argocd-credential-template"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }
  data = {
    "type"     = "git",
    "url"      = "https://github.com/${var.github_organization}",
    "username" = "git",
    "password" = var.github_token
  }

  depends_on = [module.eks, module.eks_addons]
}

resource "kubernetes_secret" "argocd_repos" {
  for_each = var.argocd_repos
  metadata {
    namespace = "argocd"
    name      = each.key
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    "url" = each.value["repo_url"]
  }

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
  depends_on = [module.eks, module.eks_addons, kubernetes_secret.argocd_repos]
}
