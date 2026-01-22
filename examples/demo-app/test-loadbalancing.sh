#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        Demo App Load Balancing Test        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo

# Check if demo-app is deployed
if ! kubectl get deployment demo-app &> /dev/null; then
    echo -e "${YELLOW}Demo app is not deployed. Deploy it first:${NC}"
    echo "  kubectl apply -f examples/demo-app/"
    exit 1
fi

# Check if pods are ready
READY_PODS=$(kubectl get pods -l app=demo-app -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -o "True" | wc -l | tr -d ' ')
TOTAL_PODS=$(kubectl get pods -l app=demo-app --no-headers | wc -l | tr -d ' ')

echo -e "${GREEN}Cluster Status:${NC}"
echo "  Ready Pods: $READY_PODS/$TOTAL_PODS"
echo

if [ "$READY_PODS" -eq 0 ]; then
    echo -e "${YELLOW}Waiting for pods to be ready...${NC}"
    kubectl wait --for=condition=Ready pods -l app=demo-app --timeout=60s
    echo
fi

# Determine the URL based on the cluster type
URL="http://localhost"

# Check if we're using kind
if kubectl config current-context | grep -q "kind"; then
    echo -e "${YELLOW}Detected Kind cluster${NC}"
    
    # Check if Ingress is installed and demo-app ingress exists
    if kubectl get namespace ingress-nginx &> /dev/null && \
       kubectl get ingress demo-app &> /dev/null; then
        echo -e "${GREEN}Ingress Controller detected - using http://localhost${NC}"
        echo "Load balancing will be handled by nginx-ingress"
        URL="http://localhost"
        
        # Check if ingress controller is ready
        INGRESS_READY=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/component=controller -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}' 2>/dev/null)
        if [ "$INGRESS_READY" != "True" ]; then
            echo -e "${YELLOW}Waiting for Ingress Controller to be ready...${NC}"
            kubectl wait --namespace ingress-nginx \
                --for=condition=ready pod \
                --selector=app.kubernetes.io/component=controller \
                --timeout=60s
        fi
    else
        echo -e "${YELLOW}Ingress not detected - using port-forward (single pod)${NC}"
        echo "Run in another terminal: kubectl port-forward svc/demo-app 8080:80"
        echo ""
        echo "For load balancing, install Ingress:"
        echo "  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
        echo "  kubectl apply -f examples/demo-app/ingress.yaml"
        URL="http://localhost:8080"
        read -r -p "Press Enter when port-forward is ready..."
    fi
elif kubectl config current-context | grep -q "minikube"; then
    echo -e "${YELLOW}Detected Minikube cluster${NC}"
    echo "Make sure 'minikube tunnel' is running in another terminal"
    read -r -p "Press Enter when tunnel is ready..."
fi

echo -e "\n${GREEN}Testing Load Balancing:${NC}"
echo "Sending 15 requests to observe pod distribution..."
echo

# Create temporary files for tracking (compatible with old bash)
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

for i in {1..15}; do
    # Make request and extract server address
    RESPONSE=$(curl -s "$URL" 2>/dev/null)
    
    if [ -z "$RESPONSE" ]; then
        echo -e "${YELLOW}Request $i: Failed to connect to $URL${NC}"
        echo "Make sure:"
        echo "  - Service is accessible (kubectl get svc demo-app)"
        echo "  - Port-forward is running (if using Kind/Minikube)"
        continue
    fi
    
    # Extract server info from HTML (nginxdemos/hello uses &nbsp; in HTML)
    SERVER_NAME=$(echo "$RESPONSE" | grep -i "Server.*name" | grep -oE '<span>[^<]+</span>' | tail -1 | sed 's/<[^>]*>//g')
    SERVER_ADDR=$(echo "$RESPONSE" | grep -i "Server.*address" | grep -oE '<span>[^<]+</span>' | tail -1 | sed 's/<[^>]*>//g' | sed 's/:80//')
    
    if [ -n "$SERVER_NAME" ]; then
        # Save pod name to temp file
        echo "$SERVER_NAME" >> "$TMP_DIR/pods.txt"
        echo -e "${GREEN}Request $i:${NC} $SERVER_NAME ($SERVER_ADDR)"
    else
        echo -e "${YELLOW}Request $i: Could not parse response${NC}"
    fi
    
    sleep 0.3
done

echo
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Load Distribution Summary         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo

if [ ! -f "$TMP_DIR/pods.txt" ]; then
    echo -e "${YELLOW}No successful requests. Check your setup.${NC}"
    exit 1
fi

# Count occurrences of each pod (compatible with old bash)
sort "$TMP_DIR/pods.txt" | uniq -c | while read -r count pod; do
    percentage=$((count * 100 / 15))
    bars=$(printf '█%.0s' $(seq 1 $((count * 2))))
    echo -e "${GREEN}$pod:${NC} $count requests (${percentage}%) ${bars}"
done

# Count unique pods
UNIQUE_PODS=$(sort "$TMP_DIR/pods.txt" | uniq | wc -l | tr -d ' ')

echo
if [ "$UNIQUE_PODS" -gt 1 ]; then
    echo -e "${GREEN}✓ Load balancing is working!${NC} Requests distributed across $UNIQUE_PODS pods"
else
    echo -e "${YELLOW}⚠ Only one pod received requests${NC}"
    echo "This might be normal if you have only one replica"
fi

echo
echo -e "${BLUE}Current Pod Status:${NC}"
kubectl get pods -l app=demo-app -o wide

echo
echo -e "${BLUE}Service Details:${NC}"
kubectl get svc demo-app

