#!/bin/bash

# This script generates the overrides.auto.tfvars file with the necessary variables to build the Tntk Final Project 2.0 infrastructure
# Prompt the user for standard variables
read -p "Enter AWS Region (e.g., us-east-2): " aws_region
read -p "Enter AWS Account ID: " aws_account_id
read -p "Enter Base Domain (e.g., dev.ernestdevops.net): " base_domain
read -p "Enter Tag Environment (e.g., dev): " tag_env
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
datadog_api_key = "$datadog_api_key"
datadog_application_key = "$datadog_application_key"
datadog_region = "$datadog_region"
github_email = "$github_email"
github_name = "$github_name"
github_organization = "$github_organization"
github_token = "$github_token"

# JSON variables
argocd_repos = {
  tntk-cd = {
    repo_url = "https://github.com/${github_organization}/tntk-cd"
    name     = "tntk-cd"
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
      repo_url        = "https://github.com/${github_organization}/tntk-cd"
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
      repo_url        = "https://github.com/${github_organization}/final-project-web"
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
      repo_url        = "https://github.com/${github_organization}/final-project-orders"
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
      repo_url        = "https://github.com/${github_organization}/final-project-auth"
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
      repo_url        = "https://github.com/${github_organization}/final-project-products"
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
      userarn  = "arn:aws:iam::${aws_account_id}:user/${github_name}"
      username = "${github_name}"
      groups   = ["system:masters"]
    }
  ]
  accounts = [
    "${aws_account_id}"
  ]
}

# Additional JSON variables can be added here

EOL

echo "overrides.auto.tfvars file has been generated."