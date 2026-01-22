# Kind - Kubernetes in Docker

Kind (Kubernetes in Docker) is a tool for running local Kubernetes clusters using Docker container "nodes".

## Installation

```bash
# Using Homebrew
brew install kind

# Verify installation
kind version
```

## Prerequisites

- Docker Desktop must be running
- kubectl installed: `brew install kubectl`

## Quick Start

### Single Node Cluster

```bash
# Create a cluster
kind create cluster --name my-cluster

# Check cluster status
kubectl cluster-info --context kind-my-cluster

# Delete cluster
kind delete cluster --name my-cluster
```

### Multi-Node Cluster

Use the configuration file provided in this directory:

```bash
# Create 3-node cluster (1 control-plane, 2 workers)
kind create cluster --name multi-node --config cluster-config.yaml

# Verify nodes
kubectl get nodes

# Delete cluster
kind delete cluster --name multi-node
```

## Features

- Multiple node support
- Port mapping from host to cluster (ports 80/443 pre-configured)
- Custom Kubernetes versions
- Ingress controller support (nginx-ingress recommended)
- Local registry integration
- Load balancing via Ingress

## Configuration Files

- `cluster-config.yaml` - Multi-node cluster configuration
- `setup.sh` - Automated cluster setup script
- `teardown.sh` - Cluster cleanup script

## Common Commands

```bash
# List all clusters
kind get clusters

# Get kubeconfig
kind get kubeconfig --name my-cluster

# Load local Docker image into cluster
kind load docker-image my-image:latest --name my-cluster

# Export logs
kind export logs --name my-cluster
```

## Accessing Services on macOS

### Understanding Kind Network Limitations

On macOS, Docker runs in a VM, which creates network isolation. This means:
- LoadBalancer services get IPs in Docker's internal network (not accessible from macOS)
- NodePort services without port mapping are not accessible
- **Ingress Controller is the recommended solution** (ports 80/443 are mapped in our config)

### Using Ingress (Recommended)

Our `cluster-config.yaml` already maps ports 80 and 443 to the control-plane node.

**1. Install nginx-ingress** (done by `setup.sh`):
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# IMPORTANT: Configure Ingress to run on control-plane node
# (ports 80/443 are mapped to control-plane in cluster-config.yaml)
kubectl label node k8s-dev-control-plane ingress-ready=true --overwrite

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

# Wait for it to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s
```

**2. Create Ingress resources for your services:**
```bash
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app
spec:
  ingressClassName: nginx
  rules:
  - http:  # Accessible via http://localhost
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80
```

**3. Access your service:**
```bash
curl http://localhost
open http://localhost
```

### Alternative: Port-Forward

For quick testing without load balancing:
```bash
kubectl port-forward svc/my-service 8080:80
curl http://localhost:8080
```

**Note:** Port-forward connects to a single pod and does not utilize Kubernetes service load balancing.

## Tips

1. **Ingress for Production-like Setup**: Use nginx-ingress for external access with load balancing
2. **Port Mapping**: Ports 80/443 are pre-configured for ingress access
3. **Local Registry**: Setup local Docker registry for faster image loading
4. **Resource Limits**: Configure Docker Desktop resources appropriately (minimum 4GB RAM, 2 CPU cores)

## Troubleshooting

### Cluster creation fails
- Ensure Docker Desktop is running
- Check Docker resource limits (CPU, Memory)
- Try: `docker system prune` to free up space

### Can't access services
- **First, check if Ingress Controller is installed:**
  ```bash
  kubectl get pods -n ingress-nginx
  ```
- **Check Ingress resources:**
  ```bash
  kubectl get ingress
  kubectl describe ingress <ingress-name>
  ```
- **Verify service and endpoints:**
  ```bash
  kubectl get svc <service-name>
  kubectl get endpoints <service-name>
  ```
- **Test Ingress directly:**
  ```bash
  curl -v http://localhost
  ```
- **Fallback: Use port-forward for debugging:**
  ```bash
  kubectl port-forward svc/<service-name> 8080:80
  curl http://localhost:8080
  ```

### Load balancing not working
- If using port-forward: This is expected - it connects to one pod only
- Solution: Use Ingress for true load balancing
- Verify Ingress is working: `kubectl get ingress`

