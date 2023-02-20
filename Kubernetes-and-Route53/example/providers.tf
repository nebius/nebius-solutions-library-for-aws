# ==================================
# Terraform & Provider Configuration
# ==================================

terraform {
  required_version = "~> 1.2.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.78.2"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.30"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "yandex" {
  endpoint = "api.cloudil.com:443"
  zone = var.zone_id
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  token = var.token
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}
