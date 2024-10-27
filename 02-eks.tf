#####################################
###          EKS MODULE           ###
#####################################

module "eks_cluster" {
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
      subnet_ids      = module.vpc.private_subnets
      iam_role_additional_policies = {
        ECRaccess = "${aws_iam_policy.ecr_parameter_policy.arn}"
      }
    }
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





