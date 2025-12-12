#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME="k8s-dev"
CONFIG_FILE="cluster-config.yaml"

echo -e "${GREEN}=== k3d Cluster Setup ===${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if k3d is installed
if ! command -v k3d &> /dev/null; then
    echo -e "${YELLOW}k3d is not installed. Installing via Homebrew...${NC}"
    brew install k3d
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}kubectl is not installed. Installing via Homebrew...${NC}"
    brew install kubectl
fi

# Check if cluster already exists
if k3d cluster list | grep -q "${CLUSTER_NAME}"; then
    echo -e "${YELLOW}Cluster '${CLUSTER_NAME}' already exists.${NC}"
    read -p "Do you want to delete and recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deleting existing cluster...${NC}"
        k3d cluster delete ${CLUSTER_NAME}
    else
        echo -e "${GREEN}Using existing cluster.${NC}"
        kubectl cluster-info
        exit 0
    fi
fi

# Create cluster
echo -e "${GREEN}Creating k3d cluster with configuration from ${CONFIG_FILE}...${NC}"
k3d cluster create --config ${CONFIG_FILE}

# Wait a moment for cluster to stabilize
echo -e "${YELLOW}Waiting for cluster to be ready...${NC}"
sleep 10

# Wait for nodes to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Display cluster info
echo -e "${GREEN}Cluster created successfully!${NC}"
echo
echo "Cluster info:"
kubectl cluster-info
echo
echo "Nodes:"
kubectl get nodes -o wide
echo

# Optional: Create local registry
read -p "Do you want to create a local Docker registry? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Creating local registry...${NC}"
    k3d registry create registry.localhost --port 5000
    
    # Connect registry to cluster
    docker network connect k3d-${CLUSTER_NAME} k3d-registry.localhost || true
    
    echo -e "${GREEN}Registry created at localhost:5000${NC}"
    echo "To use it, tag and push images like:"
    echo "  docker tag my-image:latest localhost:5000/my-image:latest"
    echo "  docker push localhost:5000/my-image:latest"
fi

# Optional: Install metrics-server
read -p "Do you want to install metrics-server? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing metrics-server...${NC}"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patch metrics-server for k3d
    kubectl patch -n kube-system deployment metrics-server --type=json \
        -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi

echo
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo
echo "To interact with the cluster, use:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"
echo
echo "LoadBalancer services will be accessible at:"
echo "  HTTP:  http://localhost:80"
echo "  HTTPS: https://localhost:443"
echo
echo "To delete the cluster later, run:"
echo "  k3d cluster delete ${CLUSTER_NAME}"
echo "  or"
echo "  ./teardown.sh"

