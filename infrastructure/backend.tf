terraform {
  backend "gcs" {
    bucket = "controlplane-483715-bindplane-tfstate"
    prefix = "infrastructure"
  }
}
