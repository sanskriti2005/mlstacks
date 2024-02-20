# defining the providers for the recipe module
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "1.0.3"
    }
  }

  backend "s3" {
    bucket = "BUCKETNAMEREPLACEME"
    region = "REGIONNAMEREPLACEME"
    key    = "terraform/state"
  }

  required_version = ">= 0.14.8"
}

provider "aws" {
  region = var.region
}
