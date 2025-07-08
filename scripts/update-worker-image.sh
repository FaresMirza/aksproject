#!/bin/bash

TAG=$1
IMAGE="faresmirza/worker-app:$TAG"
DEPLOYMENT_FILE="voting-app/k8s-specifications/worker-deployment.yaml"

if [ ! -f "$DEPLOYMENT_FILE" ]; then
  echo "❌ Deployment file not found: $DEPLOYMENT_FILE"
  exit 1
fi

echo "🔧 Updating image to $IMAGE in $DEPLOYMENT_FILE..."

# Replace the image line with the new image
sed -i "s|image: .*|image: $IMAGE|" "$DEPLOYMENT_FILE"

echo "✅ Image updated to $IMAGE"