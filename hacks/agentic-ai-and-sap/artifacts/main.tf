# Activation of Google secret manager API
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Activation of Integration connectors API
resource "google_project_service" "connectors" {
  service            = "connectors.googleapis.com"
  disable_on_destroy = false
}

# activation of Application Integration API
resource "google_project_service" "integrations" {
  service            = "integrations.googleapis.com"
  disable_on_destroy = false
}


# # Creating Application Integration Client
# resource "google_integrations_client" "us" {
#   location = "us-central1"
#   create_sample_integrations = false
#   depends_on = [ google_project_service.connectors, google_project_service.integrations, google_project_service.secretmanager ]
# }

resource "google_integrations_client" "europe" {
  location = "europe-west4"
  create_sample_integrations = false
  depends_on = [ google_project_service.connectors, google_project_service.integrations, google_project_service.secretmanager ]
}

resource "google_integration_connectors_endpoint_attachment" "sapendpointattachment" {
  name     = "saps4hana-endpoint-attachment"
  location = "europe-west4"
  description = "The SAP S/4HANA Gateway endpoint Attachment"
  service_attachment = "projects/sap-demo-iaas-d-s4-bxao/regions/europe-west4/serviceAttachments/sap-s4-demo-gateway"
  endpoint_global_access = false
  depends_on = [ google_integrations_client.europe ]
}

# Creating GCS bucket
resource "google_storage_bucket" "bucket" {
  name          = var.gcp_project_id
  storage_class = "STANDARD"
  location      = "US"
}

resource "google_storage_bucket" "bucket_recipes" {
  name          = "${var.gcp_project_id}_recipes"
  storage_class = "STANDARD"
  location      = "US"
}

resource "google_storage_bucket_object" "bucket_object_1" {
  name          = "CustomerCases.csv"
  source        = "bucket_data/CustomerCases.csv"
  bucket        = google_storage_bucket.bucket.name
  depends_on    = [google_storage_bucket.bucket]
}

resource "google_storage_bucket_object" "bucket_object_2" {
  name          = "MaterialMasterData.csv"
  source        = "bucket_data/MaterialMasterData.csv"
  bucket        = google_storage_bucket.bucket.name
  depends_on    = [google_storage_bucket.bucket]
}

resource "google_storage_bucket_object" "bucket_object_3" {
  name          = "IcecreamRecipes.pdf"
  source        = "bucket_data/IcecreamRecipes.pdf"
  bucket        = google_storage_bucket.bucket_recipes.name
  depends_on    = [google_storage_bucket.bucket_recipes]
}

data "google_iam_policy" "user" {
  binding {
    role = "roles/storage.admin"
    members = [
        "allUsers",
    ] 
  }
}

resource "google_storage_bucket_iam_policy" "policy_one" {
  bucket = "${google_storage_bucket.bucket.name}"
  policy_data = "${data.google_iam_policy.user.policy_data}"
}

module "agent_to_cloud_run" {
  source = "./adk_deployment"
  gcp_project_id = var.gcp_project_id
  gcp_region = var.gcp_region
  service_account_key_file = var.service_account_key_file
}

resource "google_storage_bucket_iam_policy" "policy_recipes" {
  bucket = "${google_storage_bucket.bucket_recipes.name}"
  policy_data = "${data.google_iam_policy.user.policy_data}"
}
