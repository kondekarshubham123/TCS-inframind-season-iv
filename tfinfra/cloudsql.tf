# Random number genrator for cloud sql as we can not use same instance name repeat
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Master database instance with all the configuration
resource "google_sql_database_instance" "master" {
  name   = "master-instance-${random_id.db_name_suffix.hex}"
  region = "us-central1"

  depends_on       = [google_service_networking_connection.private_vpc_connection]
  database_version = "MYSQL_5_7"

  settings {
    tier = "db-n1-standard-1"
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.mypronetwork.id
    }
  }
  deletion_protection = "false"
}

# root sql user for cloud-sql
resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.master.name
  host     = "%"
  password = "changeme"
}