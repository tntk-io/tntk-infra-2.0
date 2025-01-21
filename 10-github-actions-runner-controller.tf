#####################################
###            HELM               ###
#####################################

# This resource is used to install the controller for the actions runner scale set
resource "helm_release" "gha_actions_runner_controller" {
  name             = "gha-runner-scale-set-controller"
  chart            = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller"
  namespace        = "actions-runner-system"
  create_namespace = "true"

  depends_on = [module.eks]
}

# This resource is used to install the actions runner scale set for each repository
resource "helm_release" "gha_actions_runner_scale_set" {
  for_each         = var.repositories
  name             = "gha-runner-scale-set-${each.key}"
  chart            = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set"
  namespace        = "github-actions"
  create_namespace = "true"

  set {
    name  = "githubConfigUrl"
    value = "https://github.com/${var.github_organization}/${each.key}"
  }

  set {
    name  = "githubConfigSecret.github_token"
    value = var.github_token
  }
  depends_on = [module.eks, helm_release.gha_actions_runner_controller]
}
