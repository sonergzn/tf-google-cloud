#By defaults, Terrafrom excepts "providers.tf" file.
provider "google" {
  project     = var.gcloud_project_name
  region      = var.regions_europe[0]
  zone        = "europe-west1-b"
}