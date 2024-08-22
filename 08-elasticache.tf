#####################################
###          ELASTICACHE          ###
#####################################

module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = "${var.tag_env}-redis"
  create_cluster           = true
  create_replication_group = false

  engine_version    = "7.1"
  node_type         = "cache.t4g.micro"
  apply_immediately = true

  # Security group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.tag_env}-redis"
  }
}