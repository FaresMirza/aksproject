#!/bin/bash

TAG=$1
IMAGE="faresmirza/vote-app:$TAG"
DEPLOYMENT_FILE="voting-app/k8s-specifications/vote-deployment.yaml"

if [ ! -f "$DEPLOYMENT_FILE" ]; then
  echo "❌ Deployment file not found: $DEPLOYMENT_FILE"
  exit 1
fi

echo "🔧 Updating image to $IMAGE in $DEPLOYMENT_FILE..."

# ✅ عدّل فقط السطر اللي يحتوي على worker-app
sed -i "s|image:.*vote-app:.*|image: $IMAGE|" "$DEPLOYMENT_FILE"

echo "✅ Image updated to $IMAGE"