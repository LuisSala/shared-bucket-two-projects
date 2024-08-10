data "google_compute_default_service_account" "project_a_default_sa" {
  project = module.project_a.project_id
}

resource "google_compute_instance" "instance" {
  project      = module.project_a.project_id
  name         = "instance-1"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  # A firewall rule that allows access to port 80 targeting VM instances with a tag of "web" is required to access
  # the nginx container that will be running in this GCE VM instance.
  tags = ["web"]
  allow_stopping_for_update = true
  # Declare a boot disk that will use Container-optimized OS (COS)
  boot_disk {
    auto_delete = true
    device_name = "instance-disk-1"

    # Specify the Container-optimized OS (COS) image in the "initialize_params" block.
    initialize_params {
      image = "debian-12-bookworm-v20240709"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = data.google_compute_default_service_account.project_a_default_sa.email
    scopes = ["cloud-platform"]
  }

  # Configure the network interface to use your preferred network and subnetwork
  network_interface {
    subnetwork         = module.project_a.vpc.0.self_link
    subnetwork_project = module.project_a.project_id

    access_config {
      // Leave blank to use ephemeral public IP
    }
  }
}

resource "google_project_iam_member" "bucket_user" {
  project = module.project_b.project_id
  role    = "roles/storage.objectUser" # roles/storage.admin
  member  = "serviceAccount:${data.google_compute_default_service_account.project_a_default_sa.email}"
}

#
# resource "google_service_account" "gemini_sa" {
#   project      = module.project.project_id
#   account_id   = "gemini-sa"
#   display_name = "Service Account with Gemini Access"
# }
#
# # note this requires the terraform to be run regularly
# resource "time_rotating" "sa_key_rotation" {
#   rotation_days = 30
# }
#
# resource "google_service_account_key" "sa_key" {
#   service_account_id = google_service_account.gemini_sa.name
#   public_key_type    = "TYPE_X509_PEM_FILE"
#   private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
#
#   keepers = {
#     rotation_time = time_rotating.sa_key_rotation.rotation_rfc3339
#   }
# }
#
# resource "google_project_iam_custom_role" "gemini_access_role" {
#   project     = module.project.project_id
#   role_id     = "gemini_access_role"
#   title       = "Gemini access only"
#   description = "Role that allows access to gemini only"
#   permissions = ["aiplatform.endpoints.predict"]
# }


