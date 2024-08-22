#####################################
###         ECR MODULE            ###
#####################################

module "ecr" {
  name                 = "${var.tag_env}-ecr"
  source               = "cloudposse/ecr/aws"
  version              = "0.40.0"
  image_names          = ["${var.tag_env}/books", "${var.tag_env}/order", "${var.tag_env}/auth"]
  use_fullname         = true
  force_delete         = true
  image_tag_mutability = "MUTABLE"
}