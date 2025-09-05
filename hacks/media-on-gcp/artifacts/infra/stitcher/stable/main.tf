module "compute" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "stitch-machine-mig"
  base_instance_name   = "stitch-machine"
  target_size          = 1
  machine_type         = "c4d-standard-2"
  source_image         = "projects/media-on-gcp-storage/global/images/stitch-machine"
  boot_disk_type       = "hyperdisk-balanced"
  boot_disk_size       = 50

  networks             = var.networks
  sub_networks         = var.sub_networks

  metadata = {
    enable-oslogin  = "true"
  }
}

resource "google_compute_address" "stitch" {
  project = var.project_id
  region  = var.region
  name    = "stitch-vm-ip-address"
}

resource "google_endpoints_service" "dynamic" {
  project        = var.project_id
  service_name   = "stitch.endpoints.${var.project_id}.cloud.goog"
  openapi_config = <<-EOF
    swagger: "2.0"
    info:
      title: "API for davinci stitch"
      description: "A simple API for the davinci stitch service"
      version: "1.0.0"
    host: "stitch.endpoints.${var.project_id}.cloud.goog"
    x-google-endpoints:
    - name: "stitch.endpoints.${var.project_id}.cloud.goog"
      target: "${google_compute_address.stitch.address}"
    paths: {}
  EOF

  # NOTE:
  # Prevent deletion on destroy.
  # Deleteing this resource will not allow you to reuse again within 30 days. Can undelete service
  # Following, https://cloud.google.com/service-infrastructure/docs/manage-services#undeleting_a_service
  # lifecycle {
  #   prevent_destroy = true
  # }
}