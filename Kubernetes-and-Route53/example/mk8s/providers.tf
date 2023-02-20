terraform {
  required_version = "~> 1.2.3"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.78.2"
    }
  }
}
