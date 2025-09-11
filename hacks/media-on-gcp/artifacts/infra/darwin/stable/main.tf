module "compute" {
  source = "../../compute/stable"

  project_id          = var.project_id
  region              = var.region
  instance_group_name = "tx-darwin-mig"
  base_instance_name  = "tx-darwin"
  target_size         = 1
  machine_type        = "c4d-standard-8"
  source_image        = "projects/media-on-gcp-storage/global/images/tx-darwin-with-modules"
  boot_disk_size      = 50
  boot_disk_type      = "hyperdisk-balanced"

  networks            = var.networks
  sub_networks        = var.sub_networks
  external_ips        = var.external_ips

  named_ports = [{
    name = "https"
    port = 443
  }]
}
