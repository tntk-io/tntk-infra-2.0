#####################################
###         ECR MODULE            ###
#####################################

module "ecr" {
  source   = "terraform-aws-modules/ecr/aws"
  for_each = ["${var.tag_env}/books", "${var.tag_env}/order", "${var.tag_env}/auth", "${var.tag_env}/ui"]

  repository_name = each.value.name

  repository_image_scan_on_push = false

  repository_image_tag_mutability = "MUTABLE"

  repository_encryption_type = "KMS"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = each.value.count_number
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}
