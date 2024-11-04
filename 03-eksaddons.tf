module "eks_addons" {
  source            = "aws-ia/eks-blueprints-addons/aws"
  version           = "~> v1.6"
  cluster_name      = module.eks.cluster_id
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  # EKS Add-ons
  enable_aws_load_balancer_controller = true
  enable_cert_manager                 = true
  enable_external_secrets             = true
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
}