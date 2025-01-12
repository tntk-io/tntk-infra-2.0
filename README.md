![TNTK DevOps Logo](assets/tntk_devops.png)
# TNTK Infra 2.0 Documentation

## File Descriptions

### .gitignore
- **Purpose**: 
  - Ensures that sensitive and unnecessary files are not tracked by version control.
  - Helps maintain a clean repository by excluding files such as Terraform state files, backup files, and local configuration files that should not be shared or versioned.

- **Key Entries**:
  ```plaintext
  *.lock.hcl
  *.bak
  .terraform/*
  *.tfstate*
  *.tfvars*
  override.tf*
  .terraformrc
  terraform.rc
  ```

### .terraform-version
- **Purpose**: 
  - Specifies the exact version of Terraform to be used across the team to ensure consistency and avoid compatibility issues.
  - Facilitates the use of version managers to automatically switch to the correct Terraform version when working in the project directory.

- **Version**: 
  ```plaintext
  1.5.4
  ```

### 01-vpc.tf
- **Purpose**: 
  - Defines the Virtual Private Cloud (VPC) infrastructure, which is the foundational network layer for AWS resources.
  - Configures subnets, NAT gateways, and routing tables to enable secure and efficient communication between resources.

- **Key Features**:
  ```hcl
  module "vpc" {
    source  = "terraform-aws-modules/vpc/aws"
    version = "3.10.0"

    name = "my-vpc"
    cidr = "10.0.0.0/16"

    azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
    public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true
    single_nat_gateway = true

    tags = {
      Terraform   = "true"
      Environment = "dev"
    }
  }
  ```

### 02-eks.tf
- **Purpose**: 
  - Sets up an Elastic Kubernetes Service (EKS) cluster to manage containerized applications.
  - Automates the creation of Kubernetes control plane and worker nodes, ensuring scalability and high availability.

- **Key Features**:
  ```hcl
  module "eks" {
    source          = "terraform-aws-modules/eks/aws"
    cluster_name    = "my-cluster"
    cluster_version = "1.21"

    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets

    node_groups = {
      eks_nodes = {
        desired_capacity = 2
        max_capacity     = 3
        min_capacity     = 1

        instance_type = "t3.medium"
      }
    }

    tags = {
      Environment = "dev"
    }
  }
  ```

### 03-eksaddons.tf
- **Purpose**: 
  - Enhances the EKS cluster with additional capabilities such as networking, security, and monitoring.
  - Deploys essential Kubernetes add-ons like VPC CNI, CoreDNS, and others to improve cluster functionality.

- **Key Features**:
  ```hcl
  resource "aws_eks_addon" "vpc_cni" {
    cluster_name = module.eks.cluster_id
    addon_name   = "vpc-cni"
  }

  resource "aws_eks_addon" "coredns" {
    cluster_name = module.eks.cluster_id
    addon_name   = "coredns"
  }
  ```

### 04-externaldns.tf
- **Purpose**: 
  - Configures IAM roles and policies to allow External DNS to manage DNS records in Route 53.
  - Ensures that Kubernetes services can automatically update DNS records, facilitating service discovery.

- **Key Features**:
  ```hcl
  resource "aws_iam_role" "external_dns" {
    name = "external-dns-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
  }

  resource "aws_iam_policy" "external_dns_policy" {
    name        = "external-dns-policy"
    description = "Policy for External DNS to access Route 53"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "route53:ChangeResourceRecordSets",
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ]
          Resource = "*"
        }
      ]
    })
  }
  ```

### 04-externalsecrets.tf
- **Purpose**: 
  - Sets up IAM roles and policies to allow External Secrets to access AWS Secrets Manager and SSM Parameter Store.
  - Enables secure management and retrieval of secrets for applications running in Kubernetes.

- **Key Features**:
  ```hcl
  resource "aws_iam_role" "external_secrets" {
    name = "external-secrets-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
  }

  resource "aws_iam_policy" "external_secrets_policy" {
    name        = "external-secrets-policy"
    description = "Policy for External Secrets to access SSM and Secrets Manager"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue",
            "ssm:GetParameter"
          ]
          Resource = "*"
        }
      ]
    })
  }
  ```

### 05-iam.tf
- **Purpose**: 
  - Manages IAM roles and policies necessary for GitHub Actions to interact with AWS services.
  - Ensures secure and controlled access to resources like ECR and SSM, facilitating CI/CD workflows.

- **Key Features**:
  ```hcl
  resource "aws_iam_role" "github_actions" {
    name = "github-actions-role"

    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
          Action = "sts:AssumeRole"
        }
      ]
    })
  }

  resource "aws_iam_policy" "github_actions_policy" {
    name        = "github-actions-policy"
    description = "Policy for GitHub Actions to access ECR and SSM"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ssm:GetParameter"
          ]
          Resource = "*"
        }
      ]
    })
  }
  ```

### 05-rds.tf
- **Purpose**: 
  - Configures a managed PostgreSQL database instance using Amazon RDS.
  - Provides a scalable and secure database solution with automated backups and maintenance.

- **Key Features**:
  ```hcl
  module "rds" {
    source  = "terraform-aws-modules/rds/aws"
    version = "3.0.0"

    identifier = "my-rds-instance"
    engine     = "postgres"
    engine_version = "13.3"

    instance_class = "db.t3.micro"
    allocated_storage = 20

    username = "admin"
    password = "password"

    vpc_security_group_ids = [module.vpc.default_security_group_id]
    db_subnet_group_name   = module.vpc.database_subnet_group

    tags = {
      Environment = "dev"
    }
  }
  ```

### 06-ecr.tf
- **Purpose**: 
  - Sets up Amazon Elastic Container Registry (ECR) to store and manage Docker container images.
  - Implements lifecycle policies to manage image retention and optimize storage costs.

- **Key Features**:
  ```hcl
  resource "aws_ecr_repository" "my_repo" {
    name = "my-repo"

    image_tag_mutability = "MUTABLE"

    lifecycle_policy {
      policy = jsonencode({
        rules = [
          {
            rulePriority = 1
            description  = "Expire untagged images older than 30 days"
            selection    = {
              tagStatus = "untagged"
              countType = "sinceImagePushed"
              countUnit = "days"
              countNumber = 30
            }
            action = {
              type = "expire"
            }
          }
        ]
      })
    }
  }
  ```

### 07-rabbitmq.tf
- **Purpose**: 
  - Deploys a managed RabbitMQ broker using Amazon MQ for message queuing and communication between services.
  - Configures security settings and credentials to ensure secure message transmission.

- **Key Features**:
  ```hcl
  resource "aws_mq_broker" "rabbitmq" {
    broker_name = "my-rabbitmq-broker"
    engine_type = "RabbitMQ"
    engine_version = "3.8.6"

    host_instance_type = "mq.t3.micro"

    user {
      username = "admin"
      password = "password"
    }

    publicly_accessible = false

    security_groups = [module.vpc.default_security_group_id]
    subnet_ids      = module.vpc.private_subnets

    tags = {
      Environment = "dev"
    }
  }
  ```

### 08-elasticache.tf
- **Purpose**: 
  - Configures an Amazon ElastiCache cluster for Redis to provide in-memory data caching and storage.
  - Enhances application performance by reducing database load and latency.

- **Key Features**:
  ```hcl
  resource "aws_elasticache_cluster" "redis" {
    cluster_id           = "my-redis-cluster"
    engine               = "redis"
    node_type            = "cache.t3.micro"
    num_cache_nodes      = 1
    parameter_group_name = "default.redis3.2"

    subnet_group_name = module.vpc.cache_subnet_group

    security_group_ids = [module.vpc.default_security_group_id]

    tags = {
      Environment = "dev"
    }
  }
  ```

### 09-datadog.tf
- **Purpose**: 
  - Integrates AWS infrastructure with Datadog for monitoring and observability.
  - Deploys a CloudFormation stack to set up necessary resources and configurations for data collection.

- **Key Features**:
  ```hcl
  resource "aws_cloudformation_stack" "datadog" {
    name = "datadog-integration"

    template_body = file("datadog-template.yaml")

    parameters = {
      ApiKey = var.datadog_api_key
    }

    tags = {
      Environment = "dev"
    }
  }
  ```

### 10-github-actions-runners.tf
- **Purpose**: 
  - Deploys self-hosted GitHub Actions runners on Kubernetes using Helm charts.
  - Provides scalable and customizable CI/CD runners for executing workflows.

- **Key Features**:
  ```hcl
  resource "helm_release" "github_actions_runner" {
    name       = "github-actions-runner"
    repository = "https://actions-runner-controller.github.io/actions-runner-controller"
    chart      = "actions-runner-controller"

    set {
      name  = "githubToken"
      value = var.github_token
    }

    set {
      name  = "runnerImage"
      value = "my-runner-image"
    }
  }
  ```

### 11-acm.tf
- **Purpose**: 
  - Manages AWS Certificate Manager (ACM) to provision and validate SSL/TLS certificates.
  - Ensures secure communication for applications by enabling HTTPS.

- **Key Features**:
  ```hcl
  resource "aws_acm_certificate" "cert" {
    domain_name       = "example.com"
    validation_method = "DNS"

    tags = {
      Environment = "dev"
    }
  }
  ```

### 11-route53.tf
- **Purpose**: 
  - Configures Amazon Route 53 to manage DNS records for domain names.
  - Facilitates routing of internet traffic to AWS resources by setting up DNS records.

- **Key Features**:
  ```hcl
  resource "aws_route53_record" "www" {
    zone_id = var.zone_id
    name    = "www.example.com"
    type    = "A"

    alias {
      name                   = aws_lb.my_lb.dns_name
      zone_id                = aws_lb.my_lb.zone_id
      evaluate_target_health = true
    }
  }
  ```

### 12-k8s.tf
- **Purpose**: 
  - Sets up Kubernetes namespaces to logically separate and organize resources within the cluster.
  - Facilitates resource management and access control by creating distinct environments for development and production.

- **Key Features**:
  ```hcl
  resource "kubernetes_namespace" "dev" {
    metadata {
      name = "dev"
    }
  }

  resource "kubernetes_namespace" "prod" {
    metadata {
      name = "prod"
    }
  }
  ```

### 13-argocd.tf
- **Purpose**: 
  - Configures ArgoCD to manage continuous delivery of applications to Kubernetes.
  - Automates application deployment and lifecycle management using GitOps principles.

- **Key Features**:
  ```hcl
  resource "argocd_application" "my_app" {
    metadata {
      name      = "my-app"
      namespace = "argocd"
    }

    spec {
      project = "default"

      source {
        repo_url        = "https://github.com/my-org/my-repo.git"
        target_revision = "HEAD"
        path            = "path/to/app"
      }

      destination {
        server    = "https://kubernetes.default.svc"
        namespace = "dev"
      }
    }
  }
  ```

### 14-githubrepos.tf
- **Purpose**: 
  - Manages GitHub repositories to facilitate version control and collaboration.
  - Automates the creation and configuration of repositories with specified settings and topics.

- **Key Features**:
  ```hcl
  resource "github_repository" "my_repo" {
    name        = "my-repo"
    description = "My GitHub repository"
    private     = true

    topics = ["terraform", "aws", "infrastructure"]
  }
  ```

### 15-gitclone.tf
- **Purpose**: 
  - Automates the cloning and mirroring of GitHub repositories to ensure code availability and redundancy.
  - Uses local-exec provisioner to execute shell commands for repository management.

- **Key Features**:
  ```hcl
  resource "null_resource" "git_clone" {
    provisioner "local-exec" {
      command = "git clone https://github.com/my-org/my-repo.git && cd my-repo && git push --mirror https://github.com/my-org/my-mirror-repo.git"
    }
  }
  ```

### 16-github-actions-prereqs.tf
- **Purpose**: 
  - Sets up prerequisites for GitHub Actions workflows, including secrets and environment variables.
  - Ensures secure and efficient execution of CI/CD pipelines by managing sensitive information.

- **Key Features**:
  ```hcl
  variable "github_token" {
    description = "GitHub token for authentication"
    type        = string
  }

  resource "github_actions_secret" "my_secret" {
    repository = "my-repo"
    secret_name = "MY_SECRET"
    plaintext_value = var.github_token
  }
  ```

### 17-github-actions-build.tf
- **Purpose**: 
  - Triggers initial builds for GitHub Actions to validate and test configurations.
  - Uses local-exec provisioner to execute commands that initiate build processes.

- **Key Features**:
  ```hcl
  resource "null_resource" "trigger_build" {
    provisioner "local-exec" {
      command = "git commit --allow-empty -m 'Trigger build' && git push"
    }
  }
  ```

### LICENSE
- **Purpose**: 
  - Specifies the terms under which the project can be used, modified, and distributed.
  - Provides legal protection and clarity for contributors and users by defining the MIT License.

- **Content**:
  ```plaintext
  MIT License
  ...
  ```

### README.md
- **Purpose**: 
  - Provides an overview of the project, including its purpose, setup instructions, and usage examples.
  - Serves as a guide for new users to understand the project structure and get started quickly.




  ## Usage
  1. Clone the repository.
  ```sh
  git clone https://github.com/tntk-io/tntk-infra-2.0.git
  cd tntk-infra-2.0
  ```
  2. Configure your AWS credentials.
  ```sh
  aws configure
  ```
  3. Run the generate-overrides.sh script to create a terraform.tfvars file.
  ```sh
  ./generate-overrides.sh
  ```
  4. Run `terraform init` to initialize the project.
  ```sh
  terraform init
  ```
  5. Run `terraform plan` to see the changes that will be applied.
  ```sh
  terraform plan
  ```
  6. Run `terraform apply` to apply the changes.
  ```sh
  terraform apply
  ```


  ## Sample `tfvars` file:
  ```hcl
  # Standard variables
  aws_region = "us-east-2"
  aws_account_id = "98239829393"
  base_domain = "dev.ernestdevops.net"
  tag_env = "dev"
  datadog_api_key = "test"
  datadog_application_key = "test"
  datadog_region = "tes.test.com"
  github_email = "test@test.com"
  github_name = "test"
  github_organization = "ernram"
  github_token = "test"

  # JSON variables
  argocd_repos = {
    final-project-cd = {
      repo_url = "https://github.com/ernram/final-project-cd"
      name     = "final-project-cd"
    }
  }

  argocd_apps = {
    shared-resources = {
      name      = "shared-resources"
      namespace = "argocd"
      labels = {
        shared = "true"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }
      source = {
        repo_url        = "https://github.com/ernram/final-project-cd"
        chart           = "charts/dev-resources"
        target_revision = "0.0.1"
      }
      helm = {
        release_name     = "shared-resources"
        value_files_path = ["values.yaml"]
      }
    }
    tntk-web-dev = {
      name      = "tntk-api-dev"
      namespace = "argocd"
      labels = {
        environment = "dev"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "dev"
      }
      source = {
        repo_url        = "https://github.com/ernram/final-project-web"
        chart           = "charts/tntk-web"
        target_revision = "0.0.1"
      }
      helm = {
        release_name     = "tntk-api"
        value_files_path = ["../../environments/values-dev.yaml"]
      }
    }
    tntk-orders-dev = {
      name      = "tntk-web-dev"
      namespace = "argocd"
      labels = {
        environment = "dev"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "dev"
      }
      source = {
        repo_url        = "https://github.com/ernram/final-project-orders"
        chart           = "charts/tntk-orders"
        target_revision = "0.0.1"
      }
      helm = {
        release_name     = "tntk-web"
        value_files_path = ["../../environments/values-dev.yaml"]
      }
    }
    tntk-auth-dev = {
      name      = "tntk-auth-dev"
      namespace = "argocd"
      labels = {
        environment = "dev"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "dev"
      }
      source = {
        repo_url        = "https://github.com/ernram/final-project-auth"
        chart           = "charts/tntk-auth"
        target_revision = "0.0.1"
      }
      helm = {
        release_name     = "tntk-api"
        value_files_path = ["../../environments/values-dev.yaml"]
      }
    }
    tntk-products-dev = {
      name      = "tntk-products-dev"
      namespace = "argocd"
      labels = {
        environment = "dev"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "dev"
      }
      source = {
        repo_url        = "https://github.com/ernram/final-project-products"
        chart           = "charts/tntk-products"
        target_revision = "0.0.1"
      }
      helm = {
        release_name     = "tntk-products"
        value_files_path = ["../../environments/values-dev.yaml"]
      }
    }
  }

  aws_auth_config = {
    roles = []
    users = [
      {
        userarn  = "arn:aws:iam::98239829393:user/test"
        username = "test"
        groups   = ["system:masters"]
      }
    ]
    accounts = [
      "98239829393"
    ]
  }

  # Additional JSON variables can be added here
  ```

