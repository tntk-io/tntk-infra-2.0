locals {
  ecr_repos = [
    "${var.tags["Environment"]}/tntk-web",
    "${var.tags["Environment"]}/tntk-orders",
    "${var.tags["Environment"]}/tntk-auth",
    "${var.tags["Environment"]}/tntk-products"
  ]
}

#####################################
###         ECR MODULE            ###
#####################################

module "ecr" {
  source   = "terraform-aws-modules/ecr/aws"
  for_each = toset(local.ecr_repos)

  repository_force_delete = true

  repository_name = each.value

  repository_image_scan_on_push = false

  repository_image_tag_mutability = "MUTABLE"

  repository_encryption_type = "KMS"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 5 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
