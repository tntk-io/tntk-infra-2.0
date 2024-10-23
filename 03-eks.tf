#####################################
###          EKS MODULE           ###
#####################################

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.25.0"

  cluster_name    = "eks-${var.tag_env}"
  cluster_version = "1.29"
  enable_irsa     = true

  vpc_id = module.vpc.vpc_id

  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    role = {
      capacity_type   = "SPOT"
      node_group_name = "general"
      instance_types  = ["t3.medium"]
      desired_size    = "2"
      max_size        = "2"
      min_size        = "2"
      subnet_ids                   = module.vpc.private_subnets
      iam_role_additional_policies = {
        ECRaccess = "${aws_iam_policy.ecr_parameter_policy.arn}" 
      }
    }
  }
}

module "kubernetes_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> v1.17.0"
  cluster_name      = module.eks_blueprints.eks_cluster_id
  cluster_endpoint  = module.eks_blueprints.eks_cluster_endpoint
  cluster_version   = module.eks_blueprints.eks_cluster_version
  oidc_provider_arn = module.eks_blueprints.eks_oidc_provider_arn

  # EKS Add-ons
  enable_aws_load_balancer_controller = true
  enable_cert_manager   = true
  enable_external_secrets = true
  enable_argocd = true
  argocd = {
    server = {
      ingress = {
        enabled         = true
        ingressClassName = "alb"
        annotations = {
          "alb.ingress.kubernetes.io/scheme"       = "internal"
          "alb.ingress.kubernetes.io/target-type"  = "ip"
          "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTP\": 80}, {\"HTTPS\": 443}]"
          "alb.ingress.kubernetes.io/ssl-redirect" = "443"
        }
      }
      hosts = ["argo.${var.tag_env}.${var.base_domain}"]
    }
}
}


resource "aws_iam_policy" "ecr_parameter_policy" {
  name        = "ECRandParameterStorePolicy"
  description = "Policy to allow ECR operations and access to Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}





