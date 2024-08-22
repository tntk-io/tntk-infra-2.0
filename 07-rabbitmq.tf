#####################################
###          RABBITMQ             ###
#####################################


resource "aws_mq_broker" "rabbitmq" {
  broker_name = "${var.tag_env}-rabbitmq"

  engine_type                = "RabbitMQ"
  engine_version             = "3.13"
  host_instance_type         = "mq.t3.micro"
  auto_minor_version_upgrade = true
  security_groups            = [module.security_group.security_group_id]
  subnet_ids                 = [module.vpc.private_subnets[0]]

  user {
    username = random_password.rabbitmq_username.result
    password = random_password.rabbitmq_password.result
  }
}

###########################
# Supporting Resources
###########################

module "rabbitmq_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.tag_env}-rabbitmq"
  vpc_id = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Name = "${var.tag_env}-rabbitmq"
  }
}


# getting random string for rabbitmq_password
resource "random_password" "rabbitmq_password" {
  length           = 16
  special          = true
  override_special = "!#"
}

# getting random string for rabbitmq_username
resource "random_password" "rabbitmq_username" {
  length  = 7
  special = false
  numeric = false
}

## SSM PART 

# saving rabbitmq password into ssm
resource "aws_ssm_parameter" "save_rabbitmq_password_to_ssm" {
  name        = "/${var.tag_env}/rabbitmq/password"
  description = "rabbitmq password"
  type        = "SecureString"
  value       = random_password.rabbitmq_password.result
}

# saving rabbitmq admin_username into ssm
resource "aws_ssm_parameter" "save_rabbitmq_username_to_ssm" {
  name        = "/${var.tag_env}/rabbitmq/username"
  description = "rabbitmq username"
  type        = "SecureString"
  value       = random_password.rabbitmq_username.result
}

# saving rabbitmq endpoint into ssm
resource "aws_ssm_parameter" "save_rabbitmq_endpoint_to_ssm" {
  name        = "/${var.tag_env}/rabbitmq/endpoint"
  description = "rabbitmq endpoint"
  type        = "SecureString"
  value       = "amqps://${aws_mq_broker.rabbitmq.id}.mq.${data.aws_region.current}.amazonaws.com:5671"
}