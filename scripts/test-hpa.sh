#!/bin/bash

# This script tests the HPA by generating load on the application

# Get the external IP of the load balancer
SERVICE_IP=$(kubectl get svc rbt-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$SERVICE_IP" ]; then
  echo "Could not get service IP. Make sure the service is running and has an external IP."
  exit 1
fi

# Install Apache Bench if not already installed
if ! command -v ab &> /dev/null; then
  echo "Apache Bench not found. Installing..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt-get update && sudo apt-get install -y apache2-utils
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew install apache2-utils
  else
    echo "Unsupported OS. Please install Apache Bench manually."
    exit 1
  fi
fi

echo "Starting HPA test against http://$SERVICE_IP"
echo "Current pod status:"
kubectl get pods -l app=2bcloud-app

echo -e "\nCurrent HPA status:"
kubectl get hpa 2bcloud-app-hpa || echo "HPA not found. Please apply the HPA manifest first."

echo -e "\nGenerating load... (this will take about 5 minutes)"

# Generate load using Apache Bench
ab -n 100000 -c 50 http://$SERVICE_IP/stress/100 &
AB_PID=$!

# Monitor HPA in the background
(
  for i in {1..30}; do
    echo -e "\n--- HPA Status (${i}/30) ---"
    kubectl get hpa 2bcloud-app-hpa
    echo -e "\n--- Pod Status ---"
    kubectl get pods -l app=2bcloud-app
    sleep 10
  done
) &
MONITOR_PID=$!

# Wait for load test to complete
wait $AB_PID

# Clean up
kill $MONITOR_PID 2>/dev/null

echo -e "\nLoad test complete. HPA status:"
kubectl get hpa 2bcloud-app-hpa

echo -e "\nPod status after test:"
kubectl get pods -l app=2bcloud-app

echo -e "\nTest complete. The HPA should scale down the pods after the load decreases."
