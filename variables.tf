variable "base_domain" {
  type        = string
  description = "Base domain for our DNS records"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create our resources"
}

variable "github_organization" {
  type        = string
  description = "Github Organization"
}

variable "tag_env" {
  default     = "prod"
  description = "tag environment for out all resources"
}

variable "datadog_api_key" {
  type        = string
  description = "datadog api key"
}

variable "datadog_application_key" {
  type        = string
  description = "datadog application key"
}

variable "datadog_region" {
  type        = string
  description = "datadog region"
}

#####################################
### CICD variables
#####################################

# required github token
variable "github_token" {
  type        = string
  description = "registration token to register github runner for CI"
}

variable "argocd_apps" {
  type        = map(any)
  description = "ArgoCD applications to be created."

  ### Example of Usage
  # argocd_apps = {
  #   tntk-books = {
  #     name      = "tntk-books"
  #     namespace = "argocd"
  #     destination = {
  #       server    = "https://kubernetes.default.svc"
  #       namespace = "default"
  #     }
  #     source = {
  #       repo_url        = "https://github.com/tntk-io/tntk-k8s-manifests"
  #       chart           = "charts/tntk-books"
  #       target_revision = "HEAD"
  #     }
  #     helm = {
  #       release_name     = "tntk-books"
  #       value_files_path = ["values.yaml"]
  #     }
  #   }
  # }
}

variable "argocd_repos" {
  description = "Map of ArgoCD repository configuration"
  type = map(object({
    name     = string
    repo_url = string
  }))
}

variable "aws_auth_config" {
  description = "Configuration for AWS EKS authentication"
  type = object({
    roles = optional(list(object({
      rolearn  = string
      username = string
      groups   = list(string)
    }))),
    users = optional(list(object({
      userarn  = string
      username = string
      groups   = list(string)
    }))),
    accounts = optional(list(string))
  })
  default = {}
}

variable "ecr_repos" {
  description = "Map of ECR repositories and their settings"
  type = map(object({
    name         = string
    count_number = number
  }))
}

variable "eks_settings" {
  description = "Configuration settings for the EKS cluster"
  type = object({
    cluster = object({
      name                                     = string
      version                                  = string
      cluster_endpoint_public_access           = bool
      enable_cluster_creator_admin_permissions = bool
    })
    cluster_addons = map(object({
      most_recent = bool
    }))
    node_group_defaults = object({
      instance_types = list(string)
    })
    managed_node_groups = map(object({
      min_size       = number
      max_size       = number
      desired_size   = number
      instance_types = list(string)
      capacity_type  = string
    }))
    access_entries = optional(map(object({
      kubernetes_groups = list(string)
      principal_arn     = string
      policy_associations = map(object({
        policy_arn = string
        access_scope = object({
          namespaces = list(string)
          type       = string
        })
      }))
    })))
  })
}


variable "tags" {
  description = "Map of Tags to be added to resources"
  type = object({
    Environment = string
  })
}
