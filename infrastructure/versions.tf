terraform {
  required_version = ">= 1.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    bindplane = {
      source  = "observiq/bindplane"
      version = "~> 1.7"
    }
  }
}
