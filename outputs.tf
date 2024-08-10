output "project_a_id" {
  description = "The newly created project ID"
  value       = module.project_a.project_id
}

output "project_b_id" {
  description = "The newly created project ID"
  value       = module.project_b.project_id
}

output "bucket_name" {
  description = "The newly created bucket ID"
  value       = google_storage_bucket.project_b_bucket.id
}

output "external_ip" {
  value = google_compute_instance.instance.network_interface[0].access_config[0].nat_ip
}

output "gce_vm_url" {
  value = "http://${google_compute_instance.instance.network_interface[0].access_config[0].nat_ip}/"
}

output "default_service_account" {
  value = data.google_compute_default_service_account.project_a_default_sa.email
}
