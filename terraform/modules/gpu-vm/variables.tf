variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
}

variable "zone" {
  description = "The GCP zone where the VM will be created"
  type        = string
}

variable "vm_name" {
  description = "Name of the GPU VM"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the GPU VM"
  type        = string
  default     = "g2-standard-8"
}

variable "gpu_type" {
  description = "Type of GPU to attach to the VM"
  type        = string
  default     = "nvidia-l4"
}

variable "gpu_count" {
  description = "Number of GPUs to attach to the VM"
  type        = number
  default     = 1
}

variable "preemptible" {
  description = "Whether to create a preemptible VM"
  type        = bool
  default     = true
}

variable "boot_disk_size_gb" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 100
}

variable "boot_disk_image" {
  description = "The boot disk image to use for the VM. Use format 'project/family' (e.g., 'ubuntu-os-cloud/ubuntu-2204-lts')"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"  # Ubuntu 22.04 LTS image family
}

variable "static_ip" {
  description = "The static IP address to assign to the VM"
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
}

variable "service_account_email" {
  description = "Email of the service account to attach to the VM"
  type        = string
}
