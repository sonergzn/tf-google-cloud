module "outputs" {
  source = "./modules"
}

data "google_secret_manager_secret_version" "project_id" {
  #provider   = google
  secret     = "project_id"
  version    = "latest"
}

provider "google" {
  project     = var.gcloud_project_name
  region      = var.regions_europe[0]
  zone        = "europe-west1-b"
}

terraform {
    backend "remote"{
        organization = "SONER_ORG"
        workspaces {
            name = "tf-google-cloud"
        }
    }
}

resource "google_service_account" "soner_service_account" {
  account_id   = "tfserviceaccount"
  display_name = "Soner Service Account"
  project      = data.google_secret_manager_secret_version.project_id.secret_data
}

resource "google_compute_instance" "micro_google_VM" {
  name         = "test-terraform"
  machine_type = "e2-micro"
  zone         = var.google_zone

  lifecycle {
  prevent_destroy = true
    }

  tags = ["terraform", "provided"]

  boot_disk {
    auto_delete = false
    initialize_params {
      image = "debian-cloud/debian-11"
      
      labels = {
        purposes = "testing"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.soner_service_account.email
    scopes = ["cloud-platform"]
  }
}