#####################################
### RDS MODULE
#####################################

module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.tags["Environment"]}-rds"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.micro"

  allocated_storage = 10

  db_name  = random_password.rds_db_name.result
  username = random_password.rds_admin_username.result
  password = random_password.rds_password.result
  port     = 5432


  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  tags = {
    Name = "${var.tags["Environment"]}-rds"
  }


}

###########################
# Supporting Resources
###########################

module "rds_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.tags["Environment"]}-rds"
  description = "Complete PostgreSQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Name = "${var.tags["Environment"]}-rds"
  }
}

### SSM PART

# getting random string for rds_db_name
resource "random_password" "rds_db_name" {
  length  = 7
  special = false
  numeric = false
}

# getting random string for rds_password
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#"
}

# getting random string for rds_admin_username
resource "random_password" "rds_admin_username" {
  length  = 7
  special = false
  numeric = false
}

# saving rds db_name into ssm
resource "aws_ssm_parameter" "save_rds_db_name_to_ssm" {
  name        = "/${var.tags["Environment"]}/rds/db_name"
  description = "RDS DB name"
  type        = "SecureString"
  value       = module.rds.db_instance_name
}

# saving rds endpoint into ssm
resource "aws_ssm_parameter" "save_rds_endpoint_to_ssm" {
  name        = "/${var.tags["Environment"]}/rds/endpoint"
  description = "RDS endpoint"
  type        = "SecureString"
  value       = module.rds.db_instance_endpoint
}

# saving rds password into ssm
resource "aws_ssm_parameter" "save_rds_password_to_ssm" {
  name        = "/${var.tags["Environment"]}/rds/password"
  description = "RDS password"
  type        = "SecureString"
  value       = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string).password
}

# saving rds admin_username into ssm
resource "aws_ssm_parameter" "save_rds_admin_username_to_ssm" {
  name        = "/${var.tags["Environment"]}/rds/username"
  description = "RDS username"
  type        = "SecureString"
  value       = random_password.rds_admin_username.result
}