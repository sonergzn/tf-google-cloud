#output "project_id_value" {
#  value       = data.google_secret_manager_secret_version.project_id.payload
#  description = "The ID of my Google Cloud Project"
#  sensitive   = true
#}