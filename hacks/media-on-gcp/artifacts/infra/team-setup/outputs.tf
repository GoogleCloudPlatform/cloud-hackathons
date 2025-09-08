output "bucket_names" {
  description = "The names of the created team buckets."
  value = {
    ad_creative = google_storage_bucket.ad_creative.name
    hp_client   = google_storage_bucket.hp_client.name
  }
}