#!/bin/bash

# This script generates the overrides.auto.tfvars file with the necessary variables to build the Tntk Final Project 2.0 infrastructure
# Prompt the user for standard variables
read -p "Enter AWS Region (e.g., us-east-2): " aws_region
read -p "Enter AWS Account ID: " aws_account_id
read -p "Enter Base Domain (e.g., dev.ernestdevops.net): " base_domain
read -p "Enter Tag Environment (e.g., dev): " tag_env
read -p "Datadog Enabled (true/false): " datadog_enabled
read -p "Enter Datadog API Key: " datadog_api_key
read -p "Enter Datadog Application Key: " datadog_application_key
read -p "Enter Datadog Region (e.g., us5.datadoghq.com): " datadog_region
read -p "Enter GitHub Email: " github_email
read -p "Enter GitHub Name: " github_name
read -p "Enter GitHub Organization: " github_organization
read -p "Enter GitHub Token: " github_token

# Create the overrides.auto.tfvars file
cat <<EOL > overrides.auto.tfvars
# Standard variables
aws_region = "$aws_region"
aws_account_id = "$aws_account_id"
base_domain = "$base_domain"
tag_env = "$tag_env"
datadog_enabled = "$datadog_enabled"
datadog_api_key = "$datadog_api_key"
datadog_application_key = "$datadog_application_key"
datadog_region = "$datadog_region"
github_email = "$github_email"
github_name = "$github_name"
github_organization = "$github_organization"
github_token = "$github_token"

# GitHub Repositories that will be imported into ArgoCD
argocd_repos = {
  tntk-cd = {
    repo_url = "https://github.com/${github_organization}/tntk-cd"
    name     = "tntk-cd"
  }
}
# ArgoCD Applications that will be created by Terraform in ArgoCD
argocd_apps = {
  tntk-bookapp = {
    name      = "tntk-bookapp"
    namespace = "argocd"
    labels = {
      environment = "$tag_env"
    }
    destination = {
      server    = "https://kubernetes.default.svc"
      namespace = "$tag_env"
    }
    source = {
      repo_url        = "https://github.com/${github_organization}/tntk-cd"
      chart           = "charts/tntk-bookapp"
      target_revision = "0.1.0"
    }
    helm = {
      release_name     = "tntk-bookapp"
      value_files_path = ["../../environments/dev/values.yaml"]
    }
  }
}
# AWS IAM Authentication Config for the EKS cluster (this is how you add users to the cluster)
aws_auth_config = {
  roles = []
  users = [
    {
      userarn  = "arn:aws:iam::${aws_account_id}:user/${github_name}"
      username = "${github_name}"
      groups   = ["system:masters"]
    }
  ]
  accounts = [
    "${aws_account_id}"
  ]
}

# ECR repos that will be created by Terraform
ecr_repos = {
  tntk-web = {
    name         = "tntk-web"
    count_number = 10
  }
  tntk-orders = {
    name         = "tntk-orders"
    count_number = 10
  }
  tntk-auth = {
    name         = "tntk-auth"
    count_number = 10
  }
  tntk-products = {
    name         = "tntk-products"
    count_number = 10
  }
}

# EKS cluster that will be created by Terraform
eks_settings = {
  cluster = {
    name                                     = "final-project"
    version                                  = "1.31"
    cluster_endpoint_public_access           = true
    enable_cluster_creator_admin_permissions = true
  }
  cluster_addons = {
    eks-pod-identity-agent = {
      most_recent = true
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  node_group_defaults = {
    instance_types = ["t3a.small"]
  }
  # EKS node groups that will be created by Terraform
  managed_node_groups = {
    tntk_eks_nodes = {
      min_size       = 3
      max_size       = 3
      desired_size   = 3
      instance_types = ["t3a.medium"]
      capacity_type  = "SPOT"
    }
  }
}

# Repositories to create in your GitHub organization for the project
repositories = {
  tntk-auth = {
    description  = "Auth application for the final project"
    visibility   = "private"
    has_issues   = false
    has_projects = false
    has_wiki     = false
    clone_url    = "https://github.com/tntk-io/tntk-auth"
  }
  tntk-cd = {
    description  = "Manifests for the final project"
    visibility   = "public"
    has_issues   = false
    has_projects = false
    has_wiki     = false
    clone_url    = "https://github.com/tntk-io/tntk-cd-2.0"
  }
  tntk-orders = {
    description  = "Orders application for the final project"
    visibility   = "private"
    has_issues   = false
    has_projects = false
    has_wiki     = false
    clone_url    = "https://github.com/tntk-io/tntk-orders"
  }
  tntk-products = {
    description  = "Products application for the final project"
    visibility   = "private"
    has_issues   = false
    has_projects = false
    has_wiki     = false
    clone_url    = "https://github.com/tntk-io/tntk-products"
  }
  tntk-web = {
    description  = "Web application for the final project"
    visibility   = "private"
    has_issues   = false
    has_projects = false
    has_wiki     = false
    clone_url    = "https://github.com/tntk-io/tntk-web-2.0"
  }
}

# Tags to be applied to Terraform resources
tags = {
  Environment = "$tag_env"
}

# Additional JSON variables can be added here

EOL

echo "overrides.auto.tfvars file has been generated."
