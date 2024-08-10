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
  role    = "roles/storage.objectUser" # This is enough for CRUD operations on the bucket. Use roles/storage.admin for full admin privileges
  member  = "serviceAccount:${data.google_compute_default_service_account.project_a_default_sa.email}"
}


