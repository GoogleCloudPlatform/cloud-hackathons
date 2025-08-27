variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in."
  type        = string
}

variable "zone" {
  description = "The zone for the solution to be deployed."
  type        = string
  default     = null
}

variable "instance_group_name" {
  description = "The name of the managed instance group."
  type        = string
}

variable "base_instance_name" {
  description = "The base name for instances in the managed instance group."
  type        = string
}

variable "target_size" {
  description = "The number of instances in the managed instance group."
  type        = number
  default     = 1
}

variable "source_image" {
  description = "The image name for the disk for the VM instance."
  type        = string
}

variable "machine_type" {
  description = "The machine type to create, e.g. e2-small"
  type        = string
}

variable "boot_disk_type" {
  description = "The boot disk type for the VM instance."
  type        = string
  default     = "pd-balanced"
}

variable "boot_disk_size" {
  description = "The boot disk size for the VM instance in GBs"
  type        = number
  default     = 50
}

variable "networks" {
  description = "The network name to attach the VM instance."
  type        = list(string)
  default     = ["default"]
}

variable "sub_networks" {
  description = "The sub network name to attach the VM instance."
  type        = list(string)
  default     = []
}

variable "external_ips" {
  description = "The external IPs assigned to the VM for public access."
  type        = list(string)
  default     = ["EPHEMERAL"]
}

variable "ip_forward" {
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs."
  type        = bool
  default     = false
}

variable "accelerator_type" {
  description = "The accelerator type resource exposed to this instance. E.g. nvidia-tesla-p100."
  type        = string
  default     = ""
}

variable "accelerator_count" {
  description = "The number of the guest accelerator cards exposed to this instance."
  type        = number
  default     = 0
}

variable "metadata" {
  description = "Metadata to apply to the instance."
  type        = map(string)
  default     = {}
}

variable "startup_script" {
  description = "The startup script to run on the instance."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A list of network tags to apply to the instance."
  type        = list(string)
  default     = []
}

variable "service_account_email" {
  description = "The service account email to attach to the instance."
  type        = string
  default     = "default"
}

variable "service_account_scopes" {
  description = "The list of scopes to be made available for the service account."
  type        = list(string)
  default = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
  ]
}

variable "labels" {
  description = "The labels to apply to the instance."
  type        = map(string)
  default     = {}
}

variable "named_ports" {
  description = "A list of named port configurations for the instance group."
  type = any
  default = []
}
