# Minikube - Local Kubernetes

Minikube is the original and most mature tool for running Kubernetes locally.

## Installation

```bash
# Using Homebrew
brew install minikube

# Verify installation
minikube version
```

## Prerequisites

- Docker Desktop must be running (or VirtualBox/HyperKit)
- kubectl installed: `brew install kubectl`

## Quick Start

### Single Node Cluster

```bash
# Create a cluster (using Docker driver)
minikube start --driver=docker

# Check status
minikube status

# Access dashboard
minikube dashboard

# Delete cluster
minikube delete
```

### Multi-Node Cluster

```bash
# Create cluster with 3 nodes
minikube start --nodes 3 --driver=docker

# Verify nodes
kubectl get nodes

# Delete cluster
minikube delete
```

## Features

- Multiple driver support (Docker, HyperKit, VirtualBox, etc.)
- Rich addon ecosystem
- Built-in dashboard
- Multi-node support
- SSH access to nodes
- LoadBalancer support via tunnel

## Drivers

Minikube supports multiple drivers on macOS:

1. **Docker** (Recommended)
   - Fast and lightweight
   - No additional setup
   - `minikube start --driver=docker`

2. **HyperKit** (Native macOS hypervisor)
   - Better isolation
   - Requires installation: `brew install hyperkit`
   - `minikube start --driver=hyperkit`

3. **VirtualBox**
   - Cross-platform
   - Requires VirtualBox installation
   - `minikube start --driver=virtualbox`

## Addons

Minikube has a rich addon ecosystem:

```bash
# List available addons
minikube addons list

# Enable popular addons
minikube addons enable metrics-server
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable registry

# Disable addon
minikube addons disable <addon-name>
```

## Common Commands

```bash
# Start existing cluster
minikube start

# Stop cluster (preserves state)
minikube stop

# Pause cluster
minikube pause

# SSH into node
minikube ssh

# Get IP address
minikube ip

# Service URL
minikube service <service-name> --url

# Tunnel (for LoadBalancer services)
minikube tunnel

# Update Kubernetes version
minikube start --kubernetes-version=v1.28.0
```

## Configuration

### Custom Resources

```bash
# Specify CPU and memory
minikube start --cpus 4 --memory 8192

# Specify disk size
minikube start --disk-size=40g
```

### Profiles

Minikube supports multiple profiles (clusters):

```bash
# Create named profile
minikube start -p dev-cluster

# List profiles
minikube profile list

# Switch profile
minikube profile dev-cluster

# Delete profile
minikube delete -p dev-cluster
```

## Use Cases

- Full Kubernetes feature testing
- Addon exploration
- Learning Kubernetes
- Development with full K8s compatibility
- Testing with different K8s versions

## Troubleshooting

### Cluster won't start
```bash
# Delete and recreate
minikube delete
minikube start --driver=docker

# Check logs
minikube logs
```

### Service not accessible
```bash
# Use minikube tunnel
minikube tunnel

# Or port-forward
kubectl port-forward svc/my-service 8080:80

# Or get service URL
minikube service my-service --url
```

### Performance issues
```bash
# Increase resources
minikube config set cpus 4
minikube config set memory 8192
minikube delete
minikube start
```

