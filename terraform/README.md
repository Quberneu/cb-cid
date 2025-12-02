# DeepSeek Model Deployment on GCP with Terraform

This Terraform configuration sets up a production-ready deployment of a DeepSeek model on a GCP GPU instance using vLLM for serving.

## Features

- Creates a VPC with appropriate firewall rules
- Provisions a preemptible GPU VM with an NVIDIA L4 GPU
- Automatically installs NVIDIA drivers and Docker
- Deploys vLLM with the DeepSeek model as a systemd service
- Sets up proper IAM permissions and service accounts
- Includes outputs for easy access to the deployed resources

## Prerequisites

1. Google Cloud SDK installed and configured
2. Terraform 1.0+ installed
3. Sufficient GCP quotas for GPUs in your selected region
4. Billing enabled on your GCP project

## Usage

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Review the execution plan**
   ```bash
   terraform plan -var="project_id=your-project-id"
   ```

3. **Apply the configuration**
   ```bash
   terraform apply -var="project_id=your-project-id"
   ```

4. **Access the API**
   After deployment, you can access the vLLM API at:
   ```
   http://<VM_EXTERNAL_IP>:8000/v1
   ```

5. **SSH into the instance**
   ```bash
   gcloud compute ssh deepseek-gpu-vm --zone=<ZONE> --project=<PROJECT_ID>
   ```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_id | The GCP project ID | string | - |
| region | The GCP region where resources will be created | string | "us-central1" |
| zone | The GCP zone where the VM will be created | string | "us-central1-c" |
| vm_name | Name of the GPU VM | string | "deepseek-gpu-vm" |
| machine_type | Machine type for the GPU VM | string | "g2-standard-8" |
| gpu_type | Type of GPU to attach to the VM | string | "nvidia-l4" |
| gpu_count | Number of GPUs to attach to the VM | number | 1 |
| preemptible | Whether to create a preemptible VM | bool | true |
| boot_disk_size_gb | Size of the boot disk in GB | number | 100 |
| boot_disk_image | The image from which to initialize the boot disk | string | "ubuntu-2204-jammy-v20240410" |

## Outputs

| Name | Description |
|------|-------------|
| vm_instance_name | Name of the created VM instance |
| vm_external_ip | External IP address of the VM instance |
| api_endpoint | DeepSeek model API endpoint |
| ssh_command | Command to SSH into the VM |
| service_account_email | Email of the service account created for the VM |

## CI/CD Integration

This setup is designed to work with GitHub Actions. A sample workflow file is provided in `.github/workflows/deploy.yml`.

## Monitoring and Logging

To view the logs of the vLLM service:

```bash
gcloud compute ssh deepseek-gpu-vm --zone=<ZONE> --project=<PROJECT_ID> --command="sudo journalctl -u vllm.service -f"
```

## Clean Up

To destroy all resources created by this configuration:

```bash
terraform destroy -var="project_id=your-project-id"
```

## Security Considerations

- The VM is exposed to the internet on port 8000. Consider using a load balancer with HTTPS and authentication in production.
- The service account has broad permissions. In production, scope these down to the minimum required.
- Consider using VPC Service Controls for additional security.

## Troubleshooting

### GPU Driver Issues
If the GPU is not detected, SSH into the instance and check:
```bash
nvidia-smi
```

### Docker Issues
Check the Docker service status:
```bash
sudo systemctl status docker
```

### vLLM Service Issues
Check the vLLM service logs:
```bash
sudo journalctl -u vllm.service -f
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
