module "compute_nea" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "ateme-nl-mig"
  base_instance_name   = "ateme-nl"
  target_size          = 1
  machine_type         = "c4d-standard-8"
  source_image         = "projects/media-on-gcp-storage/global/images/ateme-nl-250625"
  boot_disk_type       = "hyperdisk-balanced"
  tags                 = ["http-server"]

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = var.external_ips

  named_ports = [
    {
      name = "http1"
      port = 8080
    },
    {
      name = "http2"
      port = 80
    }
  ]
}

module "compute_titan" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "ateme-tl01-mig"
  base_instance_name   = "ateme-tl01"
  target_size          = 1
  machine_type         = "c4d-standard-8"
  source_image         = "projects/media-on-gcp-storage/global/images/ateme-tl-250525"
  boot_disk_type       = "hyperdisk-balanced"
  tags                 = ["http-server"]

  networks             = var.networks
  sub_networks         = var.sub_networks
  external_ips         = var.external_ips

  named_ports = [{
    name = "https"
    port = 443
  }]
}
