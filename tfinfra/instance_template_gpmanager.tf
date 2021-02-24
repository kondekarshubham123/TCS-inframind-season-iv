# Service Account
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}


# Instance template for wordpress app
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
    scopes = ["sql-admin", "service-control", "service-management", "logging-write", "monitoring-write", "storage-rw"]
  }
}


# health check for Instance group 
resource "google_compute_health_check" "autohealing" {
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10 # 50 seconds

  http_health_check {
    request_path = "/healthz"
    port         = "8080"
  }
}

# Instance group Manager 
resource "google_compute_instance_group_manager" "wordpress-igm" {
  name = "wordpress-igm"

  base_instance_name = "wordpress-app"
  zone               = "us-central1-a"

  version {
    instance_template  = google_compute_instance_template.my-wordpress-template.id
  }

  target_size  = 1

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

# autoscaler for Instance group
resource "google_compute_autoscaler" "instance-autoscaler" {
  name   = "instance-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.wordpress-igm.self_link

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}
