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