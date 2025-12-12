# k3d - k3s in Docker

k3d is a lightweight wrapper to run k3s (Rancher Lab's minimal Kubernetes distribution) in Docker.

## Installation

```bash
# Using Homebrew
brew install k3d

# Verify installation
k3d version
```

## Prerequisites

- Docker Desktop must be running
- kubectl installed: `brew install kubectl`

## Quick Start

### Single Node Cluster

```bash
# Create a cluster
k3d cluster create my-cluster

# Check cluster status
kubectl cluster-info

# Delete cluster
k3d cluster delete my-cluster
```

### Multi-Node Cluster

```bash
# Create cluster with 3 servers (control-plane) and 3 agents (workers)
k3d cluster create multi-node \
  --servers 1 \
  --agents 2 \
  --port 8080:80@loadbalancer \
  --port 8443:443@loadbalancer

# Verify nodes
kubectl get nodes

# Delete cluster
k3d cluster delete multi-node
```

## Features

- Extremely fast startup (<30 seconds)
- Built-in LoadBalancer (Traefik)
- Automatic port mapping
- Registry support out of the box
- Volume mounts
- Multi-server (HA) setups

## Configuration

Use the configuration file:

```bash
# Create cluster from config
k3d cluster create --config cluster-config.yaml

# Or use the setup script
./setup.sh
```

## Common Commands

```bash
# List all clusters
k3d cluster list

# Start/Stop cluster
k3d cluster start my-cluster
k3d cluster stop my-cluster

# Get kubeconfig
k3d kubeconfig get my-cluster

# Import images
k3d image import my-image:latest -c my-cluster

# Create registry
k3d registry create my-registry.localhost --port 5000
```

## Advantages over Kind

1. **Speed**: Much faster cluster creation
2. **LoadBalancer**: Built-in LoadBalancer support
3. **Lightweight**: Lower resource consumption
4. **Registry**: Easier local registry setup

## Use Cases

- Rapid development cycles
- CI/CD pipelines
- Testing microservices
- Learning Kubernetes
- Development environments

## Troubleshooting

### Port already in use
```bash
# Check what's using the port
lsof -i :80
# Use different ports in config
```

### Cluster won't start
```bash
# Check Docker
docker ps
# View k3d logs
k3d cluster list
docker logs k3d-<cluster-name>-server-0
```

### Can't pull images
```bash
# Import image manually
k3d image import my-image:tag -c cluster-name
# Or use local registry
```

