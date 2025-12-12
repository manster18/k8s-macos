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
- Port mapping from host to cluster
- Custom Kubernetes versions
- Ingress controller support
- Local registry integration

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

## Tips

1. **Port Mapping**: Map ports for services (HTTP, HTTPS)
2. **Local Registry**: Setup local Docker registry for faster image loading
3. **Resource Limits**: Configure Docker Desktop resources appropriately
4. **Ingress**: Install NGINX ingress controller for easier service exposure

## Troubleshooting

### Cluster creation fails
- Ensure Docker Desktop is running
- Check Docker resource limits (CPU, Memory)
- Try: `docker system prune` to free up space

### Can't access services
- Check port mappings in config
- Verify service/ingress configuration
- Use `kubectl port-forward` as alternative

