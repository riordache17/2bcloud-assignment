#!/bin/bash
# This script generates a kubeconfig file for the AKS cluster
# and outputs it in base64 format for GitHub Secrets

# Set variables
RESOURCE_GROUP="Robert-Lordache-Candidate"
CLUSTER_NAME="rbt-aks-cluster"

# Get kubeconfig
az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --file kubeconfig.yaml --overwrite-existing

# Output base64 encoded kubeconfig
KUBE_CONFIG_BASE64=$(cat kubeconfig.yaml | base64 -w 0)
echo "KUBE_CONFIG_BASE64: $KUBE_CONFIG_BASE64"

# Clean up
rm kubeconfig.yaml
