# Create the mynetwork network
resource "google_compute_network" "mypronetwork" {
  name                    = "mypronetwork"
  auto_create_subnetworks = true
}

# Adding firewall rule for connection
resource "google_compute_firewall" "mypronetwork-allow-http-ssh-rdp-icmp" {
  name    = "mypronetwork-allow-http-ssh-rdp-icmp"
  network = google_compute_network.mypronetwork.self_link
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# Adding firewall rule for connection
resource "google_compute_firewall" "mypronetwork-wordpress-firewall-rule" {
  name    = "mypronetwork-wordpress-firewall-rule"
  network = google_compute_network.mypronetwork.self_link
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags   = ["wordpress"]
  source_ranges = ["0.0.0.0/0"]
}

# private VPC_PEERING network for cloud-sql
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.mypronetwork.id
}

# private VPC_CONNECTION for cloud-sql
resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.mypronetwork.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}