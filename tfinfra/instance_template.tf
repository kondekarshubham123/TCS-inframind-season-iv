resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_compute_instance_template" "my-wordpress-template" {
  name        = "my-wordpress-template"
  description = "This template is used to create wordpress server instances."

  tags = ["wordpress"]

  instance_description = "description assigned to instances"
  machine_type         = "e2-medium"
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  // Create a new boot disk from an image
  disk {
    source_image = "debian-cloud/debian-9"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = google_compute_network.mypronetwork.self_link
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    startup-script = file("startup-script.sh")
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["sql-admin", "service-control", "service-management", "logging-write", "monitoring-write", "storage-rw", "trace"]
  }
}
