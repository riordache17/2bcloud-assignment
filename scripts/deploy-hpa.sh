#!/bin/bash
set -e

# Build and push the Docker image
echo "Building and pushing Docker image..."
docker build -t rbtacr.azurecr.io/2bcloud-app:latest .
docker push rbtacr.azurecr.io/2bcloud-app:latest

# Apply Kubernetes manifests
echo "Applying Kubernetes manifests..."
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/hpa.yaml

# Wait for deployment to be ready
echo "Waiting for deployment to be ready..."
kubectl rollout status deployment/2bcloud-app --timeout=300s

# Get the service URL
echo "Deployment complete!"
SERVICE_IP=$(kubectl get svc rbt-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Application URL: http://$SERVICE_IP"
echo "Test HPA with: ./scripts/test-hpa.sh"
