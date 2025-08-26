module "darwin" {
  source = "../../gce-mig/stable"

  project_id          = var.project_id
  region              = var.region
  instance_group_name = "tx-darwin-mig"
  base_instance_name  = "tx-darwin"
  target_size         = 1
  machine_type        = "c4-standard-8"
  source_image        = "projects/qwiklabs-resources/global/images/tx-darwin-with-modules"
  boot_disk_size      = 50
  boot_disk_type      = "hyperdisk-balanced"

  networks            = var.networks
  sub_networks        = var.sub_networks
  external_ips        = var.external_ips

  startup_script = <<-EOT
    #!/bin/bash
    set -e

    echo ">>> Starting startup script for tx-darwin..."

    # Data Sync
    mkdir -p /var/node
    cd /var/node
    gsutil cp gs://ghacks-media-on-gcp-private/tx-deploy.tar.gz /var/node
    tar xvzf tx-deploy.tar.gz
    cd /var/node/
    chmod +x darwin-init.sh
    sudo ./darwin-init.sh
    echo ">>> Startup script for tx-darwin: finished."
  EOT

  named_ports = [{
    name = "https"
    port = 443
  }]
}
