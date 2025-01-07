terraform {
  required_version = ">= 1.5.4"
  required_providers {
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.14.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "argocd" {
  auth_token                  = data.aws_eks_cluster_auth.cluster_auth.token
  port_forward_with_namespace = true
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

# region in aws
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Team        = "Tentek DevOps"
      Project     = "DemoApp"
      Environment = "${var.tags["Environment"]}"
      ManagedBy   = "Terraform"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}