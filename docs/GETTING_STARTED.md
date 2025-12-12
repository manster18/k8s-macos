# Getting Started with Kubernetes on macOS

This guide will help you get started with running Kubernetes locally on macOS.

## Prerequisites

### Required Software

1. **Homebrew** - macOS package manager
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Docker Desktop** - Container runtime
   - Download from: https://www.docker.com/products/docker-desktop/
   - Or install via Homebrew: `brew install --cask docker`
   - Start Docker Desktop and ensure it's running

3. **kubectl** - Kubernetes command-line tool
```bash
brew install kubectl
```

### System Requirements

- **macOS**: 11.0 (Big Sur) or later
- **RAM**: Minimum 8GB (16GB recommended)
- **CPU**: 4+ cores recommended
- **Disk Space**: 20GB+ free space

## Quick Start Guide

### Option 1: k3d (Fastest - Recommended for Beginners)

Perfect for rapid development and learning.

```bash
# 1. Install k3d
brew install k3d

# 2. Create a cluster
cd k3d
./setup.sh

# 3. Verify
kubectl get nodes
```

**Time**: ~1 minute

### Option 2: Kind (Best for Multi-Node)

Great for testing and learning cluster concepts.

```bash
# 1. Install Kind
brew install kind

# 2. Create a cluster
cd kind
./setup.sh

# 3. Verify
kubectl get nodes
```

**Time**: ~2 minutes

### Option 3: Minikube (Most Features)

Best for comprehensive learning and addon exploration.

```bash
# 1. Install Minikube
brew install minikube

# 2. Create a cluster
cd minikube
./setup.sh

# 3. Verify
kubectl get nodes
```

**Time**: ~3 minutes

## Your First Kubernetes Application

Once your cluster is running, try deploying a simple application:

### 1. Deploy NGINX

```bash
# Create a deployment
kubectl create deployment nginx --image=nginx:latest

# Expose it as a service
kubectl expose deployment nginx --port=80 --type=NodePort

# Check status
kubectl get pods
kubectl get services
```

### 2. Access the Application

**For k3d:**
```bash
# Port forward
kubectl port-forward svc/nginx 8080:80

# Open browser to http://localhost:8080
```

**For Kind:**
```bash
# Port forward
kubectl port-forward svc/nginx 8080:80

# Open browser to http://localhost:8080
```

**For Minikube:**
```bash
# Get URL
minikube service nginx --url

# Or port forward
kubectl port-forward svc/nginx 8080:80
```

### 3. Clean Up

```bash
# Delete the resources
kubectl delete deployment nginx
kubectl delete service nginx
```

## Essential kubectl Commands

### Cluster Information
```bash
kubectl cluster-info              # Cluster details
kubectl get nodes                 # List nodes
kubectl get namespaces            # List namespaces
```

### Working with Pods
```bash
kubectl get pods                  # List pods in default namespace
kubectl get pods -A               # List all pods
kubectl describe pod <pod-name>   # Pod details
kubectl logs <pod-name>           # View pod logs
kubectl exec -it <pod-name> -- bash  # Shell into pod
```

### Working with Deployments
```bash
kubectl get deployments           # List deployments
kubectl create deployment <name> --image=<image>
kubectl scale deployment <name> --replicas=3
kubectl delete deployment <name>
```

### Working with Services
```bash
kubectl get services              # List services
kubectl describe service <name>   # Service details
kubectl expose deployment <name> --port=80
kubectl delete service <name>
```

### Other Useful Commands
```bash
kubectl apply -f <file.yaml>      # Apply configuration
kubectl delete -f <file.yaml>     # Delete resources
kubectl get all                   # Show all resources
kubectl port-forward svc/<service> 8080:80  # Port forwarding
```

## Directory Structure

```
k8s_macos/
├── kind/                 # Kind setup and configs
│   ├── README.md
│   ├── cluster-config.yaml
│   ├── setup.sh
│   └── teardown.sh
├── k3d/                  # k3d setup and configs
│   ├── README.md
│   ├── cluster-config.yaml
│   ├── setup.sh
│   └── teardown.sh
├── minikube/             # Minikube setup and configs
│   ├── README.md
│   ├── setup.sh
│   └── teardown.sh
├── examples/             # Example applications
├── docs/                 # Documentation
│   ├── GETTING_STARTED.md (this file)
│   └── COMPARISON.md
└── README.md
```

## Next Steps

### 1. Learn Kubernetes Basics
- Pods, Deployments, Services
- ConfigMaps and Secrets
- Persistent Volumes
- Namespaces

### 2. Try Example Applications
```bash
cd examples/
# Examples will be added here
```

### 3. Install Useful Tools

**Helm** - Kubernetes package manager
```bash
brew install helm
```

**k9s** - Terminal UI for Kubernetes
```bash
brew install k9s
```

**kubectx/kubens** - Switch contexts and namespaces easily
```bash
brew install kubectx
```

**stern** - Multi-pod log tailing
```bash
brew install stern
```

### 4. Explore Monitoring

Install metrics-server to view resource usage:
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# For Kind/k3d, you may need to patch it:
kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

# View resource usage:
kubectl top nodes
kubectl top pods
```

### 5. Try the Dashboard (Minikube)
```bash
minikube dashboard
```

## Common Issues and Solutions

### Docker Not Running
```bash
# Check if Docker is running
docker ps

# If not, start Docker Desktop from Applications
```

### Port Already in Use
```bash
# Find what's using the port
lsof -i :80

# Kill the process or use different ports in config
```

### Cluster Not Starting
```bash
# Check Docker resources (Preferences → Resources)
# Increase CPUs and Memory if needed

# Clean up and retry
kind delete cluster --name <name>  # or k3d cluster delete <name>
./setup.sh
```

### Can't Access Services
```bash
# Use port-forward as a reliable method
kubectl port-forward svc/<service-name> 8080:80

# Then access at http://localhost:8080
```

### kubectl Not Working
```bash
# Check context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context
kubectl config use-context <context-name>
```

## Learning Resources

### Official Documentation
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Kind Docs](https://kind.sigs.k8s.io/)
- [k3d Docs](https://k3d.io/)
- [Minikube Docs](https://minikube.sigs.k8s.io/)

### Tutorials
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Learn Kubernetes Basics](https://kubernetes.io/docs/tutorials/)

### Interactive Learning
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Katacoda Kubernetes Scenarios](https://www.katacoda.com/courses/kubernetes)

## Support

If you encounter issues:

1. Check the documentation in the respective tool's directory
2. Review the comparison guide: `docs/COMPARISON.md`
3. Check tool-specific troubleshooting sections
4. Search GitHub issues for the specific tool

## Tips for Success

1. **Start Simple**: Begin with k3d for fast iteration
2. **Learn kubectl**: Master the basic commands
3. **Use Configs**: Store configurations in YAML files
4. **Version Control**: Commit your Kubernetes manifests
5. **Experiment**: Don't be afraid to break things - it's local!
6. **Clean Up**: Delete unused clusters to free resources
7. **Multiple Clusters**: Use different tools for different purposes

Happy Kuberneting!

