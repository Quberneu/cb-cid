#!/bin/bash
set -e

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
   && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
   && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

apt-get update
apt-get install -y nvidia-docker2
systemctl restart docker

# Create a directory for the model
mkdir -p /var/lib/minimax

# Run MiniMax M2 container
docker run -d \
  --name minimax-m2 \
  --gpus all \
  -p 443:8000 \
  -v /var/lib/minimax:/data \
  --restart unless-stopped \
  --shm-size=16g \
  --ulimit memlock=-1 \
  --ulimit stack=67108864 \
  -e MODEL_WEIGHT_URL="${model_weight_url}" \
  minimax/m2:latest

# Enable and start the service
cat > /etc/systemd/system/minimax.service <<EOF
[Unit]
Description=MiniMax M2 Service
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a minimax-m2
ExecStop=/usr/bin/docker stop -t 2 minimax-m2

[Install]
WantedBy=default.target
EOF

systemctl daemon-reload
systemctl enable minimax.service
systemctl start minimax.service
