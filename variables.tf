variable "base_domain" {
  type        = string
  description = "Base domain for our DNS records"
}

variable "aws_region" {
  type        = string
  description = "AWS region to create our resources"
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

variable "ci_project_repo" {
  type        = string
  description = "CI project repo to register github runner"
}

variable "cd_project_repo" {
  type        = string
  description = "argo CD project repo"
}

variable "argocd_repos" {
  type = map(any)
  description = "ArgoCD repositories."
}

variable "argocd_apps" {
  type = map(any)
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
