resource "kubernetes_secret" "argocd_git_creds" {
  metadata {
    name = "argocd-credential-template"
    namespace = "argocd"
    labels = {
        "arogcd.argoproj.io/secret-type" = "repo-creds"
    }
  }
  data = {
    "type" = "git",
    "url" = "https://github.com/tntk-io",
    "username" = "git",
    "password" = var.github_token
  }

  depends_on = [ module.eks_blueprints, module.kubernetes_addons ]
}

resource "kubernetes_secret" "argocd_repos" {
  for_each = var.argocd_repos
  metadata {
    name = each.key
    namespace = "argocd"
    labels = {
        "arogcd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    "url" = each.value["repo_url"]
  }

  depends_on = [ module.eks_blueprints, module.kubernetes_addons ]
}


resource "kubernetes_manifest" "argocd_application" {
  for_each = var.argocd_apps

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = each.value["name"]
      namespace = each.value["namespace"]

      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }

    spec = {
      project = "default"

      source = {
        "repoURL"        = each.value["source"]["repo_url"]
        "path"           = each.value["source"]["chart"]
        "targetRevision" = "HEAD"

        helm = {
          "valueFiles" = each.value["helm"]["value_files_path"]
        }
      }

      destination = {
        "server"    = each.value["destination"]["server"]
        "namespace" = each.value["destination"]["namespace"]
      }

      syncPolicy = {
        automated = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}