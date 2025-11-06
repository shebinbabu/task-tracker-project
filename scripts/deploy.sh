#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <ssh-target> <docker-image> [port]"
  echo "Example: $0 ubuntu@54.123.45.67 myuser/task-tracker:latest 80"
  exit 1
fi

SSH_TARGET="$1"
IMAGE="$2"
HOST_PORT="${3:-80}"  # Default to port 80
CONTAINER_NAME="task-tracker"
CONTAINER_PORT="8000"
DATA_DIR="/opt/task-tracker-data"

echo "========================================="
echo "Deploying Task Tracker API"
echo "========================================="
echo "Target: $SSH_TARGET"
echo "Image: $IMAGE"
echo "Port: $HOST_PORT"
echo "========================================="

# Install Docker if not present
echo "Step 1: Checking Docker installation..."
ssh -o StrictHostKeyChecking=no "$SSH_TARGET" bash <<'EOF'
set -euo pipefail
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y docker.io
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ubuntu
  echo "Docker installed successfully"
else
  echo "Docker is already installed"
fi
EOF

# Deploy the container
echo ""
echo "Step 2: Deploying container..."
ssh -o StrictHostKeyChecking=no "$SSH_TARGET" bash <<EOF
set -euo pipefail

echo "Pulling latest image..."
sudo docker pull "$IMAGE"

echo "Stopping old container if exists..."
sudo docker stop "$CONTAINER_NAME" 2>/dev/null || true
sudo docker rm "$CONTAINER_NAME" 2>/dev/null || true

echo "Creating data directory..."
sudo mkdir -p "$DATA_DIR"

echo "Starting new container on port $HOST_PORT..."
sudo docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  -p $HOST_PORT:$CONTAINER_PORT \
  -v $DATA_DIR:/data \
  "$IMAGE"

echo ""
echo "Container started successfully!"
sudo docker ps | grep "$CONTAINER_NAME"
EOF

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
HOST_IP=$(echo "$SSH_TARGET" | cut -d@ -f2)
echo "API URL: http://$HOST_IP:$HOST_PORT"
echo ""
echo "Test with:"
echo "  curl http://$HOST_IP:$HOST_PORT/health"
echo "  curl http://$HOST_IP:$HOST_PORT/tasks"
echo "========================================="
