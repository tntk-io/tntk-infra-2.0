#####################################
###            HELM               ###
#####################################

resource "helm_release" "gha_actions_runner_controller" {
  name             = "gha-runner-scale-set-controller"
  chart            = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller"
  namespace        = "actions-runner-system"
  create_namespace = "true"

  depends_on = [module.eks]
}


resource "helm_release" "gha_actions_runner_scale_set" {
  name      = "gha-runner-scale-set"
  chart     = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set"
  namespace = "actions-runner-system"

  set {
    name  = "githubConfigUrl"
    value = "https://github.com/${var.github_organization}"
  }

  set {
    name  = "githubConfigSecret.github_token"
    value = var.github_token
  }
  depends_on = [module.eks, helm_release.gha_actions_runner_controller]
}
