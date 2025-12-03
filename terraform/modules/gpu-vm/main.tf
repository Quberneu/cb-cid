locals {
  startup_script = <<-EOT
    #!/bin/bash
    set -e

    # Install NVIDIA drivers
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
    curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
    
    # Update and install required packages
    apt-get update
    apt-get install -y \
      nvidia-driver-525 \
      nvidia-container-toolkit \
      docker.io \
      docker-compose

    # Add user to docker group
    usermod -aG docker $USER
    systemctl enable --now docker

    # Configure NVIDIA Container Toolkit
    nvidia-ctk runtime configure --runtime=docker --set-as-default
    systemctl restart docker

    # Create a systemd service for vLLM
    cat > /etc/systemd/system/vllm.service << EOF
[Unit]
Description=vLLM API Service
After=docker.service
Requires=docker.service

[Service]
ExecStartPre=-/usr/bin/docker stop vllm
ExecStartPre=-/usr/bin/docker rm vllm
ExecStart=/usr/bin/docker run --name vllm --gpus all -p 8000:8000 \
  vllm/vllm-openai:latest \
  --model deepseek-ai/DeepSeek-R1-Distill-Llama-8B \
  --host 0.0.0.0 \
  --port 8000 \
  --tensor-parallel-size ${var.gpu_count}
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
    EOF

    # Enable and start the service
    systemctl daemon-reload
    systemctl enable vllm.service
    systemctl start vllm.service
  EOT
}

resource "google_compute_instance" "gpu_vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["deepseek-gpu"]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size_gb
      type  = "pd-ssd"
    }
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnetwork_name
    access_config {
      nat_ip = var.static_ip
    }
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  scheduling {
    preemptible         = var.preemptible
    automatic_restart   = !var.preemptible
    on_host_maintenance = "TERMINATE"
  }

  guest_accelerator {
    type  = var.gpu_type
    count = var.gpu_count
  }

  metadata_startup_script = local.startup_script

  metadata = {
    install-nvidia-driver = "True"
  }

  # Ensure the instance has enough time to download the model
  timeouts {
    create = "60m"
    update = "60m"
  }

  # Allow the instance to be stopped by Terraform when updating configuration
  allow_stopping_for_update = true
}
