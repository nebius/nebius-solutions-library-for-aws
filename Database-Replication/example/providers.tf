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
  # shared_config_files = ["~/.aws/config"]
  # shared_credentials_files = ["~/.aws/credentials"]
}
