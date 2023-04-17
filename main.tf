module "outputs" {
  source = "./modules"
}

data "google_secret_manager_secret_version" "project_id" {
  #provider   = google
  secret     = "project_id"
  version    = "latest"
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
  display_name = "Soner Service Account for Terraform <> GoogleCloud"
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
    email        = google_service_account.soner_service_account.email
    scopes       = ["cloud-platform"]
  }
}

#################### GKE ########################

resource "google_container_cluster" "primary" {
  name     = "tfk8cluster"
  location = var.regions_europe[3]

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 3

}

resource "google_container_node_pool" "primarypreemptiblesnodes" {
  name       = "tfnodepoolgke"
  location   = var.regions_europe[3]
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    tags = ["terraformcloud","with","gke"]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.soner_service_account.email
    #scopes       = ["cloud-platform"]
  }
}