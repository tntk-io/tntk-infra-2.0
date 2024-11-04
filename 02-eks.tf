#####################################
###          EKS MODULE           ###
#####################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = var.eks_settings["cluster"]["name"]
  cluster_version                = var.eks_settings["cluster"]["version"]
  cluster_endpoint_public_access = var.eks_settings["cluster"]["cluster_endpoint_public_access"]
  cluster_addons                 = var.eks_settings["cluster_addons"]
  enable_irsa                    = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  eks_managed_node_group_defaults = {
    instance_types = var.eks_settings["node_group_defaults"]["instance_types"]
  }
  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = var.eks_settings["cluster"]["enable_cluster_creator_admin_permissions"]

  access_entries = var.eks_settings["access_entries"]

  tags = {
    Environment = var.tags["Environment"]
    Terraform   = "true"
  }
}

module "eks_cluster_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.0"

  aws_auth_roles    = var.aws_auth_config.roles
  aws_auth_users    = var.aws_auth_config.users
  aws_auth_accounts = var.aws_auth_config.accounts


  depends_on = [module.eks]
}


resource "aws_iam_policy" "eks_cluster_policy" {
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





