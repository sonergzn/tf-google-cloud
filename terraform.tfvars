#input Variables file.

variable "regions_europe" {
    type        = list(string)
    default     = ["europe-west1", "europe-west2"]
    description = "List of regions in Europa"
}

variable "gcloud_project_name" {
    type      = string
    default   = "serious-terra-383815"
    sensitive = true
}

variable "organization_name"{
    type      = string 
    default   = "SONER_ORG"
    sensitive = true
}