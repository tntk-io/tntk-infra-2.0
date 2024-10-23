#####################################
###            HELM               ###
#####################################

resource "helm_release" "actions-runner-controller" {
  name             = "gha-runner-scale-set-controller"
  chart            = "gha-runner-scale-set-controller"
  repository       = "https://actions-runner-controller.github.io/gha-runner-scale-set-controller"
  namespace        = "actions-runner-system"
  version          = "0.27.6"
  create_namespace = "true"

  depends_on = [helm_release.cert-manager, module.eks_blueprints]
}


resource "helm_release" "actions-runner-controller" {
  name             = "gha-runner-scale-set"
  chart            = "gha-runner-scale-set"
  repository       = "https://actions-runner-controller.github.io/gha-runner-scale-set"
  namespace        = "actions-runner-system"
  version          = "0.27.6"

 set {
   name = "githubConfigUrl"
   value = "https://github.com/tntk-io"
 }
 
 set {
   name = "githubConfigSecret.github_token"
   value = var.github_token
 }
  depends_on = [helm_release.cert-manager, module.eks_blueprints, helm_release.actions-runner-controller]
}

