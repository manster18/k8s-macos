#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME="minikube"
NODES=3
CPUS=4
MEMORY=8192
DRIVER="docker"

echo -e "${GREEN}=== Minikube Cluster Setup ===${NC}"

# Check if Docker is running (for docker driver)
if [ "$DRIVER" = "docker" ]; then
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
        exit 1
    fi
fi

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo -e "${YELLOW}minikube is not installed. Installing via Homebrew...${NC}"
    brew install minikube
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}kubectl is not installed. Installing via Homebrew...${NC}"
    brew install kubectl
fi

# Check if cluster already exists
if minikube status &> /dev/null; then
    echo -e "${YELLOW}Minikube cluster already exists.${NC}"
    read -p "Do you want to delete and recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deleting existing cluster...${NC}"
        minikube delete
    else
        echo -e "${GREEN}Using existing cluster.${NC}"
        kubectl cluster-info
        exit 0
    fi
fi

# Create cluster
echo -e "${GREEN}Creating Minikube cluster with ${NODES} nodes...${NC}"
echo "Configuration:"
echo "  - Nodes: ${NODES}"
echo "  - CPUs: ${CPUS}"
echo "  - Memory: ${MEMORY}MB"
echo "  - Driver: ${DRIVER}"
echo

minikube start \
    --nodes ${NODES} \
    --cpus ${CPUS} \
    --memory ${MEMORY} \
    --driver ${DRIVER}

# Wait for cluster to be ready
echo -e "${YELLOW}Waiting for cluster to be ready...${NC}"
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

# Enable addons
echo -e "${YELLOW}Enabling useful addons...${NC}"

read -p "Enable metrics-server addon? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    minikube addons enable metrics-server
fi

read -p "Enable ingress addon? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    minikube addons enable ingress
fi

read -p "Enable dashboard addon? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    minikube addons enable dashboard
    echo -e "${GREEN}Dashboard enabled! Access it with: minikube dashboard${NC}"
fi

read -p "Enable local registry addon? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    minikube addons enable registry
fi

echo
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo
echo "Useful commands:"
echo "  kubectl get nodes                    # View cluster nodes"
echo "  kubectl get pods --all-namespaces    # View all pods"
echo "  minikube dashboard                   # Open dashboard"
echo "  minikube service <service-name>      # Access a service"
echo "  minikube tunnel                      # Enable LoadBalancer services"
echo "  minikube ssh                         # SSH into node"
echo
echo "To delete the cluster later, run:"
echo "  minikube delete"
echo "  or"
echo "  ./teardown.sh"

