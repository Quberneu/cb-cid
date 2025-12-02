output "instance_name" {
  description = "The name of the VM instance"
  value       = google_compute_instance.gpu_vm.name
}

output "instance_id" {
  description = "The instance ID"
  value       = google_compute_instance.gpu_vm.instance_id
}

output "external_ip" {
  description = "The external IP address of the instance"
  value       = google_compute_instance.gpu_vm.network_interface.0.access_config.0.nat_ip
}

output "internal_ip" {
  description = "The internal IP address of the instance"
  value       = google_compute_instance.gpu_vm.network_interface.0.network_ip
}

output "self_link" {
  description = "The URI of the VM instance"
  value       = google_compute_instance.gpu_vm.self_link
}
