variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone where the VM will be created"
  type        = string
  default     = "us-central1-a"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "minimax-network"
}

variable "subnet_name" {
  description = "Name of the subnetwork"
  type        = string
  default     = "minimax-subnet"
}
