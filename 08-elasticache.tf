#####################################
###          ELASTICACHE          ###
#####################################

module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws"

  cluster_id               = "${var.tags["Environment"]}-redis"
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
    Name = "${var.tags["Environment"]}-redis"
  }
}

resource "aws_ssm_parameter" "save_redis_endpoint_to_ssm" {
  name        = "/${var.tags["Environment"]}/redis/endpoint"
  description = "Redis Endpoint"
  type        = "SecureString"
  value       = module.elasticache.cluster_cache_nodes[0].address
}