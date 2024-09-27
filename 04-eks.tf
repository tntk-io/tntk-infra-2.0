#####################################
###          EKS MODULE           ###
#####################################

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = "eks-${var.tag_env}"
  version                         = "20.2.1"
  cluster_version                 = "1.29"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  node_security_group_additional_rules = {
    ingress_source_security_group_id = {
      description              = "Ingress from another computed security group"
      protocol                 = "tcp"
      from_port                = 80
      to_port                  = 80
      type                     = "ingress"
      source_security_group_id = module.eks.node_security_group_id
    }
  }

  eks_managed_node_groups = {
    internal-service = {
      min_size                     = 2
      max_size                     = 2
      desired_size                 = 2
      disk_size                    = 50
      instance_types               = ["t3.medium"]
      capacity_type                = "SPOT"
      subnet_ids                   = module.vpc.private_subnets
      iam_role_additional_policies = {
        ECRaccess = "${aws_iam_policy.ecr_policy.arn}" 
      }
    }
  }
}


resource "aws_iam_policy" "ecr_policy" {
  name        = "ECRPushPolicy"
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

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks.cluster_name
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks.cluster_name
  ]
}

resource "kubernetes_config_map" "bookapp_configmap" {
  metadata {
    name      = "bookapp-configmap"
    namespace = "application"
  }

  data = {
    ".env" = "${templatefile("application-configmap/configmap.yaml", {
      rds_username = "${random_password.rds_admin_username.result}",
      rds_password = "${jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string).password}",
      rds_db_name = "${random_password.rds_db_name.result}",
      rds_endpoint = "${module.rds.db_instance_endpoint}",
      redis_host = "${module.elasticache.cluster_cache_nodes[0].address}",
      rabbitmq_host = "amqps://b-8dace556-4424-4896-8493-8fbda783b3be.mq.us-east-1.amazonaws.com:5671",
      rabbitmq_username = "${random_password.rabbitmq_username.result}",
      rabbitmq_password = "${random_password.rabbitmq_password.result}"
    })}"

  }
  depends_on = [ module.eks ]
}

