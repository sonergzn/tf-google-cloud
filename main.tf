provider "google" {
  project     = "serious-terra-383815"
  region      = "europe-west1"
  zone        = "europe-west1-b"
}

resource "google_service_account" "soner_service_account" {
  account_id   = "tfserviceaccount"
  display_name = "Soner Service Account"
  project      = "serious-terra-383815"
  #email        = "soner.gzn@outlook.com"
}
resource "google_compute_instance" "default" {
  name         = "test-terraform"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"


  tags = ["terraform", "provided"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        purposes = "testing"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
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