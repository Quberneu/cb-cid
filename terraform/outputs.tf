output "vm_instance_name" {
  description = "Name of the created VM instance"
  value       = module.gpu_vm.instance_name
}

output "vm_external_ip" {
  description = "External IP address of the VM instance"
  value       = module.gpu_vm.external_ip
}

output "api_endpoint" {
  description = "DeepSeek model API endpoint"
  value       = "http://${module.gpu_vm.external_ip}:8000/v1"
}

output "ssh_command" {
  description = "Command to SSH into the VM"
  value       = "gcloud compute ssh ${module.gpu_vm.instance_name} --zone=${var.zone} --project=${var.project_id}"
}

output "service_account_email" {
  description = "Email of the service account created for the VM"
  value       = google_service_account.vm_service_account.email
}
