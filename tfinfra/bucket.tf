# europe-west Region for cloud Bucket
variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "europe-west2"
}

# Creating a GCS Bucket for wordpress to store images and videos 
resource "google_storage_bucket" "my_bucket" {
  name     = "mybucketforwp"
  location = var.region
}