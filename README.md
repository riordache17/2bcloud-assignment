# 2bCloud Assignment - Azure AKS Deployment

This repository contains the infrastructure as code (IaC) and application code for deploying a Python web application to Azure Kubernetes Service (AKS) with Azure Container Registry (ACR) for container management. The solution includes:

- **Infrastructure as Code** using Terraform
- **Containerized** Python Flask application
- **CI/CD Pipeline** with GitHub Actions
- **Horizontal Pod Autoscaler (HPA)** for automatic scaling
- **Monitoring** with Prometheus metrics
- **Load testing** capabilities

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Infrastructure Provisioning](#infrastructure-provisioning)
3. [Application Deployment](#application-deployment)
4. [CI/CD Pipeline](#cicd-pipeline)
5. [Horizontal Pod Autoscaler (HPA)](#horizontal-pod-autoscaler-hpa)
6. [Verification](#verification)
7. [Cleanup](#cleanup)
8. [Troubleshooting](#troubleshooting)
9. [License](#license)

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- [Terraform](https://www.terraform.io/downloads.html) v1.0+
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- [Docker](https://www.docker.com/products/docker-desktop) installed and running
- Azure subscription with sufficient permissions
  - **Contributor** role on the subscription or resource group level
  - **Owner** role for role assignments

## Infrastructure Provisioning

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/2bcloud-assignment.git
cd 2bcloud-assignment
```

### 2. Authenticate with Azure

```bash
az login
az account set --subscription <your-subscription-id>
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Execution Plan

```bash
terraform plan
```

### 5. Apply the Infrastructure

```bash
terraform apply
```

This will create:
- Azure Resource Group
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) cluster
- Storage Account for Terraform state
- Required networking components

### 6. Configure kubectl

After Terraform completes, configure kubectl to connect to your AKS cluster:

```bash
az aks get-credentials --resource-group Robert-Lordache-Candidate --name rbt-aks-cluster --file kubeconfig
export KUBECONFIG=kubeconfig
```

## Application Deployment

### Option 1: Manual Deployment

1. **Build and Push Docker Image**

```bash
# Log in to ACR
az acr login --name rbtacr

# Build and tag the image (specify platform for compatibility)
docker build --platform linux/amd64 -t rbtacr.azurecr.io/2bcloud-app:latest .

# Push the image to ACR
docker push rbtacr.azurecr.io/2bcloud-app:latest
```

2. **Deploy to AKS**

```bash
# Apply Kubernetes manifests
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/hpa.yaml

# Verify deployment
kubectl get pods
kubectl get svc
kubectl get hpa
```

### Option 2: Using Deployment Script

```bash
# Make the script executable
chmod +x scripts/deploy-hpa.sh

# Run the deployment
./scripts/deploy-hpa.sh
```

## CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/ci-cd.yml`) automates the following:

1. **On push to main branch**:
   - Builds the Docker image
   - Pushes to Azure Container Registry (ACR)
   - Deploys to AKS
   - Runs smoke tests
   - Deploys HPA configuration

### Setup CI/CD

1. **Fork this repository** to your GitHub account

2. **Configure GitHub Secrets**:
   - `ACR_NAME`: Your ACR name (e.g., 'rbtacr')
   - `ACR_USERNAME`: ACR admin username (from Azure Portal -> ACR -> Access Keys)
   - `ACR_PASSWORD`: ACR admin password
   - `KUBE_CONFIG`: Base64-encoded kubeconfig (generate using `scripts/generate-kubeconfig.sh`)

3. **Push to main branch** to trigger the workflow

## Installation and Usage

### 1. Clone the repository
```bash
git clone <repository-url>
cd 2bcloud-assignment
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the execution plan
```bash
terraform plan
```

### 4. Apply the configuration
```bash
terraform apply
```

### 5. Configure kubectl
After the infrastructure is created, configure kubectl to connect to your AKS cluster:
```bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl get nodes
```

### 6. Verify the cluster is running
```bash
kubectl get all --all-namespaces
```

## Usage
*Usage instructions will be added here*

## Project Structure

```
2bcloud-assignment/
├── .github/workflows/    # GitHub Actions workflows
│   └── ci-cd.yml        # CI/CD pipeline definition
├── app/                 # Web application source code
│   ├── app.py           # Main application code (Flask)
│   └── requirements.txt # Python dependencies
├── kubernetes/          # Kubernetes manifests
│   ├── deployment.yaml  # Application deployment
│   └── hpa.yaml         # Horizontal Pod Autoscaler config
├── scripts/             # Utility scripts
│   ├── deploy-hpa.sh    # Deployment script
│   ├── generate-kubeconfig.sh  # Kubeconfig generator
│   └── test-hpa.sh      # HPA testing script
├── .gitignore          # Git ignore file
├── README.md           # This file
├── backend.tf          # Terraform backend config
├── main.tf             # Main Terraform configuration
├── variables.tf        # Variable declarations
├── outputs.tf          # Output values
├── providers.tf        # Provider configurations
└── Dockerfile          # Docker configuration
```

## Resource Configuration

### Azure Container Registry (ACR)
- Basic SKU container registry
- Admin access enabled
- Geo-replication disabled (can be enabled for production)
- Used for storing and managing Docker container images

### Azure Kubernetes Service (AKS)
- Single node pool with 1 node
- Standard_DS2_v2 VM size
- System-assigned managed identity
- Kubenet networking plugin
- Standard load balancer
- Default node pool with 1 node (Standard_DS2_v2)
- Integrated with ACR for private container image access

### Azure Storage Account
- Standard LRS storage account for Terraform state
- Private container for state files
- Minimum TLS version 1.2

## Implementation Details

### Terraform State Management
- The Terraform state is stored in an Azure Storage Account for team collaboration
- The storage account name is unique to avoid conflicts
- Sensitive data is properly marked as sensitive in outputs

### Security Considerations
- System-assigned managed identity for AKS
- Latest stable Kubernetes version
- Secure defaults for networking and access control

### Cost Optimization
- Single node pool with minimal resources for development
- Standard_DS2_v2 VMs provide a good balance of performance and cost
- All resources are tagged for cost tracking

## Horizontal Pod Autoscaler (HPA)

The application includes a Horizontal Pod Autoscaler (HPA) that automatically scales the number of pods based on CPU and memory usage.

### HPA Configuration
- **Minimum Pods**: 2
- **Maximum Pods**: 10
- **CPU Target**: 50% utilization
- **Memory Target**: 70% utilization

### Testing HPA

1. **Deploy the HPA**:
   ```bash
   kubectl apply -f kubernetes/hpa.yaml
   ```

2. **Generate Load**:
   ```bash
   ./scripts/test-hpa.sh
   ```
   This script will:
   - Generate load using Apache Bench
   - Monitor HPA status
   - Show pod scaling in real-time

3. **Monitor Scaling**:
   ```bash
   # Watch HPA status
   watch -n 5 kubectl get hpa
   
   # Watch pod status
   watch -n 5 kubectl get pods
   
   # View resource usage
   kubectl top pods
   ```

4. **Verify Auto-scaling**:
   - Under load, the number of pods should increase
   - When load decreases, pods should scale back down

## Verification

### 1. Verify Application Access

Get the external IP of the LoadBalancer service:

```bash
kubectl get svc rbt-app-service
```

Access the application in your browser or using curl:

```bash
EXTERNAL_IP=$(kubectl get svc rbt-app-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP
```

### 2. Test Health Endpoint

```bash
curl http://$EXTERNAL_IP/healthz
```

### 3. Test HPA Endpoint (for load testing)

```bash
# This will generate CPU load
curl http://$EXTERNAL_IP/stress/100
```

### 4. Check Logs

```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=2bcloud-app -o jsonpath='{.items[0].metadata.name}')

# View logs
kubectl logs $POD_NAME
```

## Cleanup

To destroy all created resources:

```bash
# Delete Kubernetes resources
kubectl delete -f kubernetes/hpa.yaml
kubectl delete -f kubernetes/deployment.yaml

# Destroy Terraform-managed resources
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Docker not running**:
   - Ensure Docker Desktop is running
   - Run `docker ps` to verify

2. **Image Pull Backoff Error**:
   - Ensure the image is built with the correct platform: `docker build --platform linux/amd64 -t rbtacr.azurecr.io/2bcloud-app:latest .`
   - Verify the image was pushed to ACR: `az acr repository list --name rbtacr`
   - Check pod events: `kubectl describe pod <pod-name>`

3. **ACR authentication issues**:
   ```bash
   # Login to ACR
   az acr login --name rbtacr
   
   # Or with admin credentials
   az acr login --name rbtacr --username <acr-username> --password $(az acr credential show --name rbtacr --query "passwords[0].value" -o tsv)
   ```

4. **Kubernetes connection issues**:
   ```bash
   # Get AKS credentials
   az aks get-credentials --resource-group Robert-Lordache-Candidate --name rbt-aks-cluster --file kubeconfig
   export KUBECONFIG=$(pwd)/kubeconfig
   ```

5. **HPA not scaling**:
   - Check metrics server is running: `kubectl get deployment metrics-server -n kube-system`
   - Check HPA events: `kubectl describe hpa 2bcloud-app-hpa`
   - Check resource metrics: `kubectl top pods`
   - Verify CPU requests/limits in deployment

## CI/CD Pipeline

This project includes a GitHub Actions workflow for continuous integration and deployment. The pipeline will:

1. Build a Docker image of the application
2. Push the image to Azure Container Registry (ACR)
3. Deploy the application to AKS
4. Run smoke tests to verify the deployment
5. Deploy the HPA configuration

### Prerequisites

1. Fork this repository to your GitHub account
2. Set up the following GitHub Secrets in your repository:
   - `ACR_NAME`: Your ACR name (e.g., 'rbtacr')
   - `ACR_USERNAME`: ACR admin username (from Azure Portal -> ACR -> Access Keys)
   - `ACR_PASSWORD`: ACR admin password (from Azure Portal -> ACR -> Access Keys)
   - `KUBE_CONFIG`: Base64-encoded kubeconfig file (see below)

### Setting up Kubernetes Access

To generate the kubeconfig for GitHub Actions:

```bash
# Make the script executable
chmod +x scripts/generate-kubeconfig.sh

# Run the script (requires Azure CLI and jq)
./scripts/generate-kubeconfig.sh
```

Copy the output `KUBE_CONFIG_BASE64` value and add it as a GitHub Secret named `KUBE_CONFIG`.

### Manual Deployment

For manual deployment to AKS, you can use the deployment script:

```bash
# Make the script executable
chmod +x scripts/deploy-hpa.sh

# Run the deployment
./scripts/deploy-hpa.sh
```

Or perform the steps manually:

```bash
# Build and push the image
az acr login --name <acr-name>
docker build -t <acr-name>.azurecr.io/2bcloud-app:latest .
docker push <acr-name>.azurecr.io/2bcloud-app:latest

# Deploy to AKS
kubectl apply -f kubernetes/deployment.yaml
kubectl apply -f kubernetes/hpa.yaml

# Check the deployment
kubectl get pods
kubectl get service 2bcloud-app-service
kubectl get hpa
```

## Container Registry Usage

### Building and Pushing to ACR

1. Build the Docker image:
   ```bash
   docker build -t 2bcloud-app .
   ```

2. Log in to your ACR:
   ```bash
   az acr login --name <your-acr-name>
   ```

3. Tag the image with ACR login server:
   ```bash
   docker tag 2bcloud-app <acr-name>.azurecr.io/2bcloud-app:latest
   ```

4. Push the image to ACR:
   ```bash
   docker push <acr-name>.azurecr.io/2bcloud-app:latest
   ```

5. After applying the Terraform configuration, the AKS cluster will have pull access to this ACR.

## Testing

### Local Testing

1. Navigate to the app directory:
   ```bash
   cd app
   ```

2. Run the application locally:
   ```bash
   python -m pip install -r requirements.txt
   python app.py
   ```

3. Test the endpoints:
   ```bash
   curl http://localhost:5000
   curl http://localhost:5000/healthz
   ```

### Container Testing

1. Build the Docker image:
   ```bash
   docker build -t 2bcloud-app .
   ```

2. Run the container:
   ```bash
   docker run -p 5000:5000 2bcloud-app
   ```

3. Test the endpoints as shown above.

### AKS Cluster Testing

1. Verify AKS cluster:
   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```

### Test Application Deployment
1. Deploy a sample application:
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

2. Get the external IP:
```bash
kubectl get svc nginx
```

3. Clean up test resources:
```bash
kubectl delete deployment nginx
kubectl delete service nginx
```

## Cleanup
To destroy all created resources and avoid unnecessary charges:

```bash
terraform destroy
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.