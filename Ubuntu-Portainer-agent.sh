#!/bin/bash

set -e

echo "[*] Updating system and installing prerequisites..."
apt-get update -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    software-properties-common

echo "[*] Adding Docker GPG key and repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[*] Installing Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "[*] Enabling Docker to start on boot..."
systemctl enable docker
systemctl start docker

echo "[*] Creating Docker volume for Portainer agent..."
docker volume create portainer_agent_data

echo "[*] Pulling and starting Portainer agent container..."
docker run -d \
  -p 9001:9001 \
  --name portainer_agent \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_agent_data:/data \
  portainer/agent

echo "[✔] Portainer agent installed and running on port 9001."
echo "⚠ Ensure your main Portainer server can reach this machine on TCP port 9001."
