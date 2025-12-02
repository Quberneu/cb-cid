variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region where the network will be created"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}
