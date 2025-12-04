terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }

  # Use GCS for remote state storage
  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Enable required GCP services
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

# Network
module "network" {
  source       = "../terraform/modules/network"
  project_id   = var.project_id
  region       = var.region
  network_name = "minimax-network"
}

# Static IP
resource "google_compute_address" "static_ip" {
  name   = "minimax-ip"
  region = var.region
}

# GPU VM
module "gpu_vm" {
  source                = "../terraform/modules/gpu-vm"
  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  network_name          = module.network.network_name
  subnetwork_name       = module.network.subnet_name
  vm_name               = "minimax-gpu-vm"
  machine_type          = "a2-highgpu-1g" # Updated for MiniMax M2
  gpu_type              = "nvidia-tesla-a100"
  gpu_count             = 1
  preemptible           = true
  boot_disk_size_gb     = 200                                                             # Increased for model weights
  boot_disk_image       = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts" # Using Ubuntu 22.04 LTS image family
  static_ip             = google_compute_address.static_ip.address
  service_account_email = google_service_account.vm_service_account.email

  depends_on = [
    google_project_service.services,
    google_service_account.vm_service_account,
    google_project_iam_member.compute_admin,
    google_project_iam_member.storage_admin,
    google_project_iam_member.iam_service_account_user,
    google_project_iam_member.monitoring_editor,
  ]
}

# Import existing service account
import {
  to = google_service_account.vm_service_account
  id = "projects/ultra-sunset-472113-j0/serviceAccounts/minimax-vm-sa@ultra-sunset-472113-j0.iam.gserviceaccount.com"
}

# Service Account
resource "google_service_account" "vm_service_account" {
  account_id   = "minimax-vm-sa"
  display_name = "Service Account for MiniMax GPU VM"
  project      = var.project_id
}

# IAM Role Bindings
resource "google_project_iam_member" "compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "iam_service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

resource "google_project_iam_member" "monitoring_editor" {
  project = var.project_id
  role    = "roles/monitoring.editor"
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}