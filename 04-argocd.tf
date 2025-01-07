resource "argocd_repository_credentials" "github" {
  url = "https://github.com/tntk-io"
  username = "git" 
  password = var.github_token

  depends_on = [ module.eks_blueprints, module.kubernetes_addons ]
}

resource "argocd_repository" "repos" {
  for_each = var.argocd_repos
  
  name = each.key
  repo = each.value["repo_url"]
  type = "git"

  depends_on = [ module.eks_blueprints, module.kubernetes_addons ]
}


resource "argocd_application" "application" {
  for_each = var.argocd_apps

  metadata {
    name      = each.value["name"]
    namespace = each.value["namespace"]
    finalizers = [
      "resources-finalizer.argocd.argoproj.io"
    ]
  }

  spec {
    project = "default"

    source {
      repo_url        = each.value["source"]["repo_url"]
      path           = each.value["source"]["chart"]
      target_revision = "HEAD"

      helm {
        value_files = each.value["helm"]["value_files_path"]
      }
    }

    destination {
      server    = each.value["destination"]["server"]
      namespace = each.value["destination"]["namespace"]
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
      }
    }
  }
}