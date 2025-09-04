module "compute" {
  source = "../../compute/stable"

  project_id           = var.project_id
  region               = var.region
  instance_group_name  = "stitcher-machine-mig"
  base_instance_name   = "stitcher-machine"
  target_size          = 1
  machine_type         = "e2-medium"
  source_image         = "projects/media-on-gcp-storage/global/images/stitcher-machine"
  boot_disk_type       = "pd-balanced"
  boot_disk_size       = 50

  networks             = var.networks
  sub_networks         = var.sub_networks

  metadata = {
    enable-oslogin  = "true"
    startup_script = <<-EOT
      #!/bin/bash
      set -e # Exit immediately if a command exits with a non-zero status.

      echo ">>> Starting startup script..."

      cat <<EOF > request-create-config.json
{
  "sourceUri": "https://cdn.endpoints.${var.project_id}.cloud.goog/live/disk0/channel1/HLS/channel1.m3u8",
  "adTagUri": "https://pubads.g.doubleclick.net/gampad/live/ads?sz=640x480&output=xml_vast3&iu=/6353/christophen/IBC2025_hackathon&env=vp&impl=s&gdfp_req=1&unviewed_position_start=1&ad_rule=0",
  "defaultSlate": "projects/669648730623/locations/europe-west1/slates/testslate",
  "gamLiveConfig": {
    "networkCode": "6353"
  },
  "adTracking": "SERVER"
}
EOF

      curl -X POST \
          -H "Authorization: Bearer $(gcloud auth print-access-token)" \
          -H "x-goog-user-project: 669648730623" \
          -H "Content-Type: application/json; charset=utf-8" \
          -d @request-create-config.json \
          "https://videostitcher.googleapis.com/v1/projects/669648730623/locations/europe-west1/liveConfigs?liveConfigId=${var.project_id}"

      echo ">>> Startup script finished."
    EOT
  }
}

