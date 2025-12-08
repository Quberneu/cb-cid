# DeepSeek Model Deployment on GCP with Terraform and GitHub Actions

This guide provides comprehensive instructions for deploying a DeepSeek model on Google Cloud Platform using Terraform and GitHub Actions.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
  - [1. GCP Service Account Setup](#1-gcp-service-account-setup)
  - [2. GitHub Repository Secrets](#2-github-repository-secrets)
  - [3. Deploying the Infrastructure](#3-deploying-the-infrastructure)
  - [4. Testing the Model API](#4-testing-the-model-api)
  - [5. Tearing Down the Infrastructure](#5-tearing-down-the-infrastructure)
- [Repository Structure](#repository-structure)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Prerequisites

- A Google Cloud Platform (GCP) account with billing enabled
- Sufficient quota for NVIDIA L4 GPUs in your selected region
- GitHub account
- Basic knowledge of Terraform and GCP

## Setup Instructions

### 1. GCP Service Account Setup

1. Go to the [GCP Console](https://console.cloud.google.com/)
2. Navigate to "IAM & Admin" > "Service Accounts"
3. Click "Create Service Account"
4. Name it `terraform-deployer` and click "Create"
5. Add the following roles:
   - Compute Admin (`roles/compute.admin`)
   - Compute Network Admin (`roles/compute.networkAdmin`)
   - Service Account User (`roles/iam.serviceAccountUser`)
   - Storage Admin (`roles/storage.admin`)
   - Artifact Registry Admin (`roles/artifactregistry.admin`)
6. Click "Done"
7. Select the service account and go to the "Keys" tab
8. Click "Add Key" > "Create new key"
9. Choose JSON format and save the key file securely

### 2. GitHub Repository Secrets

1. Go to your GitHub repository
2. Navigate to "Settings" > "Secrets and variables" > "Actions"
3. Click "New repository secret" and add the following secrets:
   - `GCP_CREDENTIALS`: Paste the entire contents of the JSON key file you downloaded
   - `GCP_PROJECT_ID`: Your GCP project ID
   - `GCP_REGION`: (Optional) Default: `us-central1`
   - `GCP_ZONE`: (Optional) Default: `us-central1-c`
   - `TF_STATE_BUCKET`: (Optional) GCS bucket name for storing Terraform state

### 3. Deploying the Infrastructure

The deployment will automatically trigger when you push to the `main` branch. You can also trigger it manually:

1. Push your code to the `main` branch
2. Go to the "Actions" tab in your GitHub repository
3. Monitor the workflow execution
4. Once complete, the VM will be provisioned and the DeepSeek model will start loading

### 4. Testing the Model API

Once deployed, you can test the API using curl:

```bash
curl http://<VM_PUBLIC_IP>:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-ai/DeepSeek-R1-Distill-Llama-8B",
    "prompt": "Hello, how are you?",
    "max_tokens": 100
  }'
```

### 5. Tearing Down the Infrastructure

To destroy all resources when you're done:

1. Go to the "Actions" tab
2. Run the workflow manually with the `workflow_dispatch` event
3. Add `terraform destroy` as an input parameter

Or run locally:

```bash
cd terraform
terraform destroy -var="project_id=your-project-id"
```

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml     # GitHub Actions workflow
├── terraform/
│   ├── main.tf              # Main Terraform configuration
│   ├── variables.tf         # Variable definitions
│   ├── outputs.tf           # Output definitions
│   └── modules/
│       ├── network/         # Network module
│       └── gpu-vm/          # GPU VM module
└── README.md                # Project overview
```

## Troubleshooting

### Common Issues

1. **Insufficient Quota**
   - Check your GCP quota for GPUs in the selected region
   - Request a quota increase if needed

2. **Authentication Errors**
   - Verify the service account JSON key is correctly set in GitHub Secrets
   - Ensure the service account has all required permissions

3. **VM Fails to Start**
   - Check the serial console logs in GCP Console
   - Verify the startup script in `modules/gpu-vm/main.tf`

4. **API Not Responding**
   - Check if the VM is running
   - Verify the vLLM service is running: `sudo systemctl status vllm`
   - Check the logs: `sudo journalctl -u vllm.service -f`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
