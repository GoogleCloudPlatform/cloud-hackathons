output "bucket_names" {
  description = "The names of the created team buckets."
  value = {
    ad_creative = google_storage_bucket.ad_creative.name
    hp_client   = google_storage_bucket.hp_client.name
  }
}

output "api_response" {
  description = "The response from the API call."
  value       = jsondecode(data.http.api_call.response_body)
}
