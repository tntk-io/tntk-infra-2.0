#####################################
###         VPC MODULE            ###
#####################################

module "vpc" {
  source                             = "terraform-aws-modules/vpc/aws"
  version                            = "5.12.0"
  name                               = "${var.tag_env}-VPC"
  cidr                               = "10.0.0.0/16"
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  create_database_subnet_route_table = false
  azs                                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets                    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets                     = ["10.0.4.0/24", "10.0.5.0/24"]
  database_subnets                   = ["10.0.41.0/24", "10.0.42.0/24"]

  tags                     = { "Name" = "${var.tag_env}-VPC" }
  database_subnet_tags     = { "Name" = "${var.tag_env}-Database-Subnet" }
  private_route_table_tags = { "Name" = "${var.tag_env}-Private-Route-Table" }
  public_route_table_tags  = { "Name" = "${var.tag_env}-Public-Route-Table" }
  public_subnet_tags = {
    "Name"                                     = "${var.tag_env}-Public-Subnet",
    "kubernetes.io/role/elb"                   = 1,
    "kubernetes.io/cluster/eks-${var.tag_env}" = "owned"
  }
  private_subnet_tags = {
    "Name"                                     = "${var.tag_env}-Private-Subnet",
    "kubernetes.io/role/internal-elb"          = 1,
    "kubernetes.io/cluster/eks-${var.tag_env}" = "owned"
  }

}
