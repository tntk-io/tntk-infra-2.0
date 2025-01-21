module "eks_addons" {
  source            = "aws-ia/eks-blueprints-addons/aws"
  version           = "~> v1.19"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Add-ons
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_argocd                       = true
  argocd = {
    server = {
      ingress = {
        enabled          = true
        ingressClassName = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"       = "internal"
          "alb.ingress.kubernetes.io/target-type"  = "ip"
          "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
          "alb.ingress.kubernetes.io/ssl-redirect" = "443"
        }
      }
      hosts = ["argo.${var.tags["Environment"]}.${var.base_domain}"]
    }
  }
  depends_on = [module.eks]
}

resource "null_resource" "delay_between_addons" {
  provisioner "local-exec" {
    command = "sleep 120"
  }

  depends_on = [module.eks_addons]
}

module "additional_addons" {
  source            = "aws-ia/eks-blueprints-addons/aws"
  version           = "~> v1.19"
  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_cert_manager     = true
  enable_external_secrets = true
  depends_on              = [module.eks, null_resource.delay_between_addons, aws_iam_role.external_secrets_role]
}