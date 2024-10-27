data "aws_route53_zone" "base_domain" {
  name = var.base_domain
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }
}

data "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = module.rds.db_instance_master_user_secret_arn  # Replace with your secret ARN
}
