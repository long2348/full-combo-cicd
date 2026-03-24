#!/bin/bash

# Configuration
IMAGE="tamtm019/solar-app:v1.0.0"
CONTAINER_NAME="solar-app"
HOST_PORT=80
CONTAINER_PORT=80

# Function to check if nerdctl exists
if command -v nerdctl &> /dev/null; then
    CMD="sudo nerdctl"
elif command -v crictl &> /dev/null; then
    CMD="sudo crictl"
    # Note: crictl doesn't run containers directly, use ctr instead
    CMD_CTR="sudo ctr"
else
    echo "Neither nerdctl nor crictl found. Installing nerdctl..."
    wget https://github.com/containerd/nerdctl/releases/download/v1.7.0/nerdctl-1.7.0-linux-amd64.tar.gz
    tar -xzf nerdctl-1.7.0-linux-amd64.tar.gz
    sudo mv nerdctl /usr/local/bin/
    CMD="sudo nerdctl"
fi

# Pull image
echo "Pulling image: $IMAGE"
$CMD pull $IMAGE

# Stop and remove existing container if exists
echo "Removing existing container if exists..."
$CMD stop $CONTAINER_NAME 2>/dev/null || true
$CMD rm $CONTAINER_NAME 2>/dev/null || true

# Run container
echo "Running container..."
if [ "$CMD" = "sudo crictl" ]; then
    # crictl doesn't run containers directly, use ctr
    sudo ctr container create $IMAGE $CONTAINER_NAME
    sudo ctr task start $CONTAINER_NAME
else
    $CMD run -d \
        --name $CONTAINER_NAME \
        -p $HOST_PORT:$CONTAINER_PORT \
        --restart unless-stopped \
        $IMAGE
fi

# Check status
echo "Deployment status:"
$CMD ps | grep $CONTAINER_NAME

echo "Application should be running on port $HOST_PORT"