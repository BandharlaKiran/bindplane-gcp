resource "google_service_account" "terraform" {
  account_id   = "bindplane-terraform"
  display_name = "Bindplane Terraform CI"
}

resource "google_project_iam_member" "compute" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_project_iam_member" "storage" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_storage_bucket" "tf_state" {
  name     = "${var.project_id}-bindplane-tfstate"
  location = var.region

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
