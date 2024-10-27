<a id="readme-top"></a>



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">TNTK Infra 2.0</h3>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project
This repo contains the Terraform code for building the tntk-io 2.0 final project



### Built With

* [![Terraform][terraform-image]][terraform-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

Run the following commands to install prereqs for this final project.
* ```sh
    brew install tfenv gh
  ```

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/tntk-io/tntk-infra-2.0.git
   ```
2. Create a tfvars override file
   
3. Fill out all variables in override file using your account details
   
4. Run Terraform commands to build project
   ```sh
   terraform init
   terraform plan -out my.plan
   terraform apply
   ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Here is a sample tfvars override file you can use as a template.
```
# Standard variables
aws_region = "us-east-2"
base_domain = "mydomain.test"
tag_env = "dev"
datadog_api_key = "MYAPIKEY"
datadog_application_key = "MYAPPKEY"
datadog_region = "us5.datadoghq.com"
github_token = "MYGITHUBTOKEN"



# CICD overrides
argocd_repos = {
  test = {
    repo_url = "https://github.com/${var.base_domain}/test"
    name     = "test"
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
      repo_url        = "https://github.com/tntk-io/tntk-k8s-manifests"
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
      repo_url        = "https://github.com/tntk-io/tntk-web-2.0"
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
      repo_url        = "https://github.com/tntk-io/tntk-orders"
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
      repo_url        = "https://github.com/tntk-io/tntk-auth"
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
      repo_url        = "https://github.com/tntk-io/tntk-products"
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
  roles = [
    # {
    #   rolearn  = "arn:aws:iam::66666666666:role/role1"
    #   username = "role1"
    #   groups   = ["system:masters"]
    # }
  ],
  users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/ernest.ramirez"
      username = "ernest.ramirez"
      groups   = ["system:masters"]
    }
  ],
  accounts = [
    "${data.aws_caller_identity.current.account_id}"
  ]
}

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
```

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[terraform-image]: https://static-00.iconduck.com/assets.00/terraform-icon-452x512-ildgg5fd.png
[terraform-url]: https://terraform.io
