locals {
  ecr_repos = [
    "${var.tags["Environment"]}/books",
    "${var.tags["Environment"]}/auth",
    "${var.tags["Environment"]}/ui",
    "${var.tags["Environment"]}/order"
  ]
}

#####################################
###         ECR MODULE            ###
#####################################

module "ecr" {
  source   = "terraform-aws-modules/ecr/aws"
  for_each = toset(local.ecr_repos)

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
