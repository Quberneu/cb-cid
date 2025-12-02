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
  description = "The image from which to initialize the boot disk"
  type        = string
  default     = "ubuntu-2204-jammy-v20240410"
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
