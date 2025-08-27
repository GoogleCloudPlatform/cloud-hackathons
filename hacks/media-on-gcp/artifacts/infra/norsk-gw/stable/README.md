# Google Cloud Marketplace Terraform Module

This module deploys a product from Google Cloud Marketplace.

## Usage
The provided test configuration can be used by executing:

```
terraform plan --var-file marketplace_test.tfvars --var project_id=<YOUR_PROJECT>
```

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | The ID of the project in which to provision resources. | `string` | `null` | yes |
| goog_cm_deployment_name | The name of the deployment and VM instance. | `string` | `null` | yes |
| source_image | The image name for the disk for the VM instance. | `string` | `"projects/id3as-public/global/images/norsk-studio-byol-debian-12-x86-64-2025-05-13"` | no |
| zone | The zone for the solution to be deployed. | `string` | `"us-central1-a"` | no |
| machine_type | The machine type to create, e.g. e2-small | `string` | `"e2-standard-8"` | no |
| boot_disk_type | The boot disk type for the VM instance. | `string` | `"pd-balanced"` | no |
| boot_disk_size | The boot disk size for the VM instance in GBs | `number` | `25` | no |
| networks | The network name to attach the VM instance. | `list(string)` | `["default"]` | no |
| sub_networks | The sub network name to attach the VM instance. | `list(string)` | `[]` | no |
| external_ips | The external IPs assigned to the VM for public access. | `list(string)` | `["EPHEMERAL"]` | no |
| ip_forward | Whether to allow sending and receiving of packets with non-matching source or destination IPs. | `bool` | `false` | no |
| enable_tcp_80 | Allow HTTP traffic from the Internet (optional, redirects to HTTPS) | `bool` | `true` | no |
| tcp_80_source_ranges | Source IP ranges for HTTP traffic | `string` | `""` | no |
| enable_tcp_443 | Allow HTTPS traffic from the Internet | `bool` | `true` | no |
| tcp_443_source_ranges | Source IP ranges for HTTPS traffic | `string` | `""` | no |
| enable_tcp_3478 | Allow TCP port 3478 (STUN/TURN) traffic from the Internet | `bool` | `true` | no |
| tcp_3478_source_ranges | Source IP ranges for TCP port 3478 traffic | `string` | `""` | no |
| enable_udp_3478 | Allow UDP port 3478 (STUN/TURN) traffic from the Internet | `bool` | `true` | no |
| udp_3478_source_ranges | Source IP ranges for UDP port 3478 traffic | `string` | `""` | no |
| enable_udp_5001 | Allow UDP port 5001 traffic (example SRT port) from the Internet | `bool` | `true` | no |
| udp_5001_source_ranges | Source IP ranges for UDP port 5001 traffic | `string` | `""` | no |
| accelerator_type | The accelerator type resource exposed to this instance. E.g. nvidia-tesla-p100. | `string` | `"nvidia-tesla-p100"` | no |
| accelerator_count | The number of the guest accelerator cards exposed to this instance. | `number` | `0` | no |
| domain_name | The domain name that you will access this Norsk Studio deployment through, which you must set up through your DNS provider to point to the VM instance. | `string` | `null` | no |
| certbot_email | The email where you will receive HTTPS certificate expiration notices from Let's Encrypt. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| site_url | Site Url |
| admin_user | Username for Admin password. |
| admin_password | Password for Admin. |
| instance_self_link | Self-link for the compute instance. |
| instance_zone | Zone for the compute instance. |
| instance_machine_type | Machine type for the compute instance. |
| instance_nat_ip | External IP of the compute instance. |
| instance_network | Self-link for the network of the compute instance. |

## Requirements
### Terraform

Be sure you have the correct Terraform version (1.2.0+), you can choose the binary here:

https://releases.hashicorp.com/terraform/

### Configure a Service Account
In order to execute this module you must have a Service Account with the following project roles:

- `roles/compute.admin`
- `roles/iam.serviceAccountUser`

If you are using a shared VPC:

- `roles/compute.networkAdmin` is required on the Shared VPC host project.

### Enable API
In order to operate with the Service Account you must activate the following APIs on the project where the Service Account was created:

- Compute Engine API - `compute.googleapis.com`
