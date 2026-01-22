#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

CLUSTER_NAME="k8s-dev"
CONFIG_FILE="cluster-config.yaml"

echo -e "${GREEN}=== Kind Cluster Setup ===${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running. Please start Docker Desktop.${NC}"
    exit 1
fi

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo -e "${YELLOW}kind is not installed. Installing via Homebrew...${NC}"
    brew install kind
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${YELLOW}kubectl is not installed. Installing via Homebrew...${NC}"
    brew install kubectl
fi

# Check if cluster already exists
if kind get clusters 2>&1 | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${YELLOW}Cluster '${CLUSTER_NAME}' already exists.${NC}"
    read -p "Do you want to delete and recreate it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Deleting existing cluster...${NC}"
        kind delete cluster --name ${CLUSTER_NAME}
    else
        echo -e "${GREEN}Using existing cluster.${NC}"
        kubectl cluster-info --context kind-${CLUSTER_NAME}
        exit 0
    fi
fi

# Create cluster
echo -e "${GREEN}Creating Kind cluster with configuration from ${CONFIG_FILE}...${NC}"
kind create cluster --config ${CONFIG_FILE}

# Wait for cluster to be ready
echo -e "${YELLOW}Waiting for cluster to be ready...${NC}"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Display cluster info
echo -e "${GREEN}Cluster created successfully!${NC}"
echo
echo "Cluster info:"
kubectl cluster-info --context kind-${CLUSTER_NAME}
echo
echo "Nodes:"
kubectl get nodes -o wide
echo

# Optional: Install metrics-server
read -p "Do you want to install metrics-server? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing metrics-server...${NC}"
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    
    # Patch metrics-server for Kind
    kubectl patch -n kube-system deployment metrics-server --type=json \
        -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
fi

# Install ingress-nginx (recommended for Kind on macOS)
echo -e "${YELLOW}Note: Kind on macOS requires Ingress for external access with load balancing.${NC}"
echo -e "${YELLOW}LoadBalancer services work internally, but Ingress provides host access.${NC}"
echo
read -p "Install NGINX Ingress Controller? (recommended) (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Installing NGINX Ingress Controller...${NC}"
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    
    echo -e "${YELLOW}Configuring Ingress for control-plane node...${NC}"
    # Label control-plane node for ingress
    kubectl label node ${CLUSTER_NAME}-control-plane ingress-ready=true --overwrite
    
    # Patch deployment to run on control-plane (where ports 80/443 are mapped)
    # Must add both nodeSelector AND toleration
    kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[
      {
        "op": "add",
        "path": "/spec/template/spec/nodeSelector/ingress-ready",
        "value": "true"
      },
      {
        "op": "add",
        "path": "/spec/template/spec/tolerations",
        "value": [
          {
            "effect": "NoSchedule",
            "key": "node-role.kubernetes.io/control-plane",
            "operator": "Equal"
          }
        ]
      }
    ]'
    
    echo -e "${YELLOW}Waiting for ingress controller to be ready...${NC}"
    kubectl wait --namespace ingress-nginx \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=300s
    
    echo -e "${GREEN}Ingress Controller ready! Services accessible via http://localhost${NC}"
    INGRESS_INSTALLED=true
else
    echo -e "${YELLOW}Skipping Ingress installation.${NC}"
    echo -e "${YELLOW}Note: You'll need to use kubectl port-forward to access services.${NC}"
    INGRESS_INSTALLED=false
fi

echo
echo -e "${GREEN}=== Setup Complete! ===${NC}"
echo
echo "To interact with the cluster, use:"
echo "  kubectl get nodes"
echo "  kubectl get pods --all-namespaces"
echo
echo -e "${YELLOW}=== Next Steps ===${NC}"
echo
echo "1. Deploy demo application to test your cluster:"
echo "   kubectl apply -f examples/demo-app/"
echo
if [ "${INGRESS_INSTALLED}" = true ]; then
    echo "2. Access the app via Ingress (with load balancing):"
    echo "   # Wait for demo-app to be ready, then:"
    echo "   curl http://localhost"
    echo "   open http://localhost"
    echo
    echo "   Note: Add 'demo.local' to /etc/hosts for custom domain:"
    echo "   echo '127.0.0.1 demo.local' | sudo tee -a /etc/hosts"
    echo "   curl http://demo.local"
else
    echo "2. Access the app via port-forward (single pod):"
    echo "   kubectl port-forward svc/demo-app 8080:80"
    echo "   open http://localhost:8080"
    echo
    echo "   For load balancing, install Ingress Controller:"
    echo "   See kind/README.md for instructions"
fi
echo
echo "3. Test load balancing:"
echo "   bash examples/demo-app/test-loadbalancing.sh"
echo
echo "4. View detailed demo instructions:"
echo "   cat examples/demo-app/README.md"
echo
echo "To delete the cluster later, run:"
echo "  kind delete cluster --name ${CLUSTER_NAME}"
echo "  or"
echo "  ./teardown.sh"

