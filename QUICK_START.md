# Quick Start Guide

## Get Started in 3 Steps

### Step 1: Install Tools

```bash
# Run the installation script
./common/install-tools.sh

# This will install:
# - kubectl (Kubernetes CLI)
# - Your choice of: Kind, k3d, or Minikube
# - Optional tools: helm, k9s, kubectx, etc.
```

### Step 2: Create a Cluster

Choose one based on your needs:

#### Option A: k3d (Fastest - Recommended)
```bash
cd k3d
./setup.sh
```
**Use when**: You want the fastest startup and lightweight cluster

#### Option B: Kind (Best for Multi-Node)
```bash
cd kind
./setup.sh
```
**Use when**: You need to test multi-node scenarios

#### Option C: Minikube (Most Features)
```bash
cd minikube
./setup.sh
```
**Use when**: You want to explore Kubernetes features and addons

### Step 3: Deploy Your First App

```bash
# Deploy hello-world example
kubectl apply -f examples/hello-world/deployment.yaml

# Check status
kubectl get pods
kubectl get services

# Access the app
kubectl port-forward svc/hello-world 8080:80
# Open browser to http://localhost:8080

# Clean up
kubectl delete -f examples/hello-world/deployment.yaml
```

## What's Included

```
k8s_macos/
├── README.md                      # Project overview
├── QUICK_START.md                 # This file
├── LICENSE                        # MIT License
├── .gitignore                     # Git ignore rules
│
├── kind/                          # Kind (Kubernetes in Docker)
│   ├── README.md                  # Kind documentation
│   ├── cluster-config.yaml        # Multi-node configuration
│   ├── setup.sh                   # Create cluster script
│   └── teardown.sh                # Delete cluster script
│
├── k3d/                           # k3d (k3s in Docker)
│   ├── README.md                  # k3d documentation
│   ├── cluster-config.yaml        # Multi-node configuration
│   ├── setup.sh                   # Create cluster script
│   └── teardown.sh                # Delete cluster script
│
├── minikube/                      # Minikube
│   ├── README.md                  # Minikube documentation
│   ├── setup.sh                   # Create cluster script
│   └── teardown.sh                # Delete cluster script
│
├── common/                        # Shared utilities
│   └── install-tools.sh           # Install all tools
│
├── examples/                      # Example applications
│   └── hello-world/
│       ├── README.md
│       └── deployment.yaml        # Simple NGINX demo
│
└── docs/                          # Documentation
    ├── GETTING_STARTED.md         # Comprehensive guide
    ├── COMPARISON.md              # Solution comparison
    └── ARCHITECTURE.md            # Technical details
```

## Solution Comparison at a Glance

| Aspect | k3d | Kind | Minikube |
|--------|-----|------|----------|
| **Speed** | Fastest | Fast | Slower |
| **Resources** | Low | Medium | High |
| **Multi-Node** | Yes (Easy) | Yes (Easy) | Yes (Good) |
| **Learning Curve** | Easy | Easy | Easy |
| **LoadBalancer** | Built-in | External | Tunnel |
| **Best For** | Development | Testing | Learning |

## Common Commands

### Cluster Management
```bash
# Kind
kind create cluster --config kind/cluster-config.yaml
kind get clusters
kind delete cluster --name <name>

# k3d
k3d cluster create --config k3d/cluster-config.yaml
k3d cluster list
k3d cluster delete <name>

# Minikube
minikube start --nodes 3
minikube status
minikube delete
```

### Kubernetes Basics
```bash
# View cluster
kubectl get nodes
kubectl get pods -A
kubectl get services

# Deploy app
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Scale
kubectl scale deployment nginx --replicas=3

# Logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow

# Shell into pod
kubectl exec -it <pod-name> -- bash

# Port forwarding
kubectl port-forward svc/<service> 8080:80

# Clean up
kubectl delete deployment nginx
kubectl delete service nginx
```

## Troubleshooting

### Docker Not Running
```bash
# Check if Docker is running
docker ps

# If not, start Docker Desktop from Applications
```

### Cluster Won't Start
```bash
# Delete and recreate
cd kind  # or k3d, minikube
./teardown.sh
./setup.sh
```

### Can't Access Services
```bash
# Use port-forward (works everywhere)
kubectl port-forward svc/<service-name> 8080:80

# Then access: http://localhost:8080
```

### Check Cluster Status
```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

## Next Steps

1. **Read the full guide**: `docs/GETTING_STARTED.md`
2. **Compare solutions**: `docs/COMPARISON.md`
3. **Learn architecture**: `docs/ARCHITECTURE.md`
4. **Try examples**: Explore `examples/` directory

## Learning Resources

- [Official Kubernetes Docs](https://kubernetes.io/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [k3d Documentation](https://k3d.io/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/)

## Contributing to This Project

This repository is open for contributions. Feel free to:
- Add more examples
- Improve scripts
- Add documentation
- Submit pull requests

## System Requirements

- **OS**: macOS 11.0+ (Big Sur or later)
- **RAM**: 8GB minimum (16GB recommended)
- **Disk**: 20GB free space
- **CPU**: 4+ cores recommended

## Optional Tools to Install

```bash
# Terminal UI for Kubernetes
brew install k9s

# Switch between contexts/namespaces easily
brew install kubectx

# View logs from multiple pods
brew install stern

# Kubernetes package manager
brew install helm

# Configuration management
brew install kustomize
```

## You're Ready!

Choose your cluster solution and start developing with Kubernetes on your Mac!

For detailed information, see `README.md` and `docs/GETTING_STARTED.md`.

---
Happy Kuberneting!
