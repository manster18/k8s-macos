# Architecture Overview

This document explains the architecture of different local Kubernetes solutions and how they work on macOS.

## High-Level Architecture

### Traditional Approach (VM-based)
```
┌─────────────────────────────────────┐
│         macOS Host                  │
│  ┌───────────────────────────────┐  │
│  │   Virtual Machine (VM)        │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │  Linux OS               │  │  │
│  │  │  ┌───────────────────┐  │  │  │
│  │  │  │   Kubernetes      │  │  │  │
│  │  │  │   Components      │  │  │  │
│  │  │  └───────────────────┘  │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### Modern Approach (Container-based)
```
┌─────────────────────────────────────┐
│         macOS Host                  │
│  ┌───────────────────────────────┐  │
│  │   Docker Desktop              │  │
│  │  ┌──────┐  ┌──────┐  ┌──────┐│  │
│  │  │ Node │  │ Node │  │ Node ││  │
│  │  │  1   │  │  2   │  │  3   ││  │
│  │  │(Cont)│  │(Cont)│  │(Cont)││  │
│  │  └──────┘  └──────┘  └──────┘│  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Solution-Specific Architectures

### 1. Kind Architecture

```
┌─────────────────────────────────────────────────────┐
│                  macOS Host                         │
│                                                     │
│  ┌────────────────────────────────────────────┐   │
│  │         Docker Desktop                      │   │
│  │                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐       │   │
│  │  │ Control      │  │ Worker       │       │   │
│  │  │ Plane        │  │ Node 1       │       │   │
│  │  │ Container    │  │ Container    │       │   │
│  │  │              │  │              │       │   │
│  │  │ - API Server │  │ - kubelet    │       │   │
│  │  │ - etcd       │  │ - containerd │ ...   │   │
│  │  │ - scheduler  │  │ - kube-proxy │       │   │
│  │  │ - controller │  │              │       │   │
│  │  └──────────────┘  └──────────────┘       │   │
│  │         ↑                  ↑               │   │
│  │         └──────────────────┘               │   │
│  │           Docker Network                   │   │
│  └────────────────────────────────────────────┘   │
│                      ↑                             │
│                      │                             │
│                  Port Mapping                      │
│                (80, 443, 6443)                     │
└─────────────────────────────────────────────────────┘
```

**Key Points:**
- Each node is a Docker container
- Control plane runs full Kubernetes components
- Workers run kubelet and containerd
- Networking via Docker bridge network
- Port mapping for external access

### 2. k3d Architecture

```
┌─────────────────────────────────────────────────────┐
│                  macOS Host                         │
│                                                     │
│  ┌────────────────────────────────────────────┐   │
│  │         Docker Desktop                      │   │
│  │                                             │   │
│  │  ┌──────────────┐     ┌──────────────┐    │   │
│  │  │ k3s Server   │     │ k3s Agent    │    │   │
│  │  │ Container    │ ... │ Container    │    │   │
│  │  │              │     │              │    │   │
│  │  │ - API Server │     │ - kubelet    │    │   │
│  │  │ - SQLite     │     │ - containerd │    │   │
│  │  │ - Scheduler  │     │              │    │   │
│  │  └──────────────┘     └──────────────┘    │   │
│  │         ↑                     ↑            │   │
│  │  ┌──────┴─────────────────────┴─────┐     │   │
│  │  │      Load Balancer Container     │     │   │
│  │  │          (Traefik)               │     │   │
│  │  └──────────────────────────────────┘     │   │
│  │                   ↑                        │   │
│  └───────────────────┼────────────────────────┘   │
│              Port Mapping (80, 443)                │
└─────────────────────────────────────────────────────┘
```

**Key Points:**
- Uses lightweight k3s instead of full Kubernetes
- SQLite instead of etcd (less resource usage)
- Built-in Traefik load balancer
- Faster startup due to simplified components
- Agent nodes instead of worker nodes

### 3. Minikube Architecture (Docker Driver)

```
┌─────────────────────────────────────────────────────┐
│                  macOS Host                         │
│                                                     │
│  ┌────────────────────────────────────────────┐   │
│  │         Docker Desktop                      │   │
│  │                                             │   │
│  │  ┌──────────────────────────────────┐      │   │
│  │  │  Minikube Container              │      │   │
│  │  │                                  │      │   │
│  │  │  ┌────────────────────────┐      │      │   │
│  │  │  │  Full K8s Cluster      │      │      │   │
│  │  │  │                        │      │      │   │
│  │  │  │  - API Server          │      │      │   │
│  │  │  │  - etcd                │      │      │   │
│  │  │  │  - Controller Manager  │      │      │   │
│  │  │  │  - Scheduler           │      │      │   │
│  │  │  │  - kubelet             │      │      │   │
│  │  │  │  - kube-proxy          │      │      │   │
│  │  │  │  - containerd/docker   │      │      │   │
│  │  │  │  - Addons (optional)   │      │      │   │
│  │  │  └────────────────────────┘      │      │   │
│  │  └──────────────────────────────────┘      │   │
│  │                   ↑                         │   │
│  └───────────────────┼─────────────────────────┘   │
│              Port Mapping / Tunnel                  │
└─────────────────────────────────────────────────────┘
```

**Key Points:**
- Single container running full Kubernetes
- All components in one container
- Rich addon system
- Multiple driver options
- Higher resource usage but full compatibility

### 4. Docker Desktop Kubernetes

```
┌─────────────────────────────────────────────────────┐
│                  macOS Host                         │
│                                                     │
│  ┌────────────────────────────────────────────┐   │
│  │      Docker Desktop (Built-in K8s)         │   │
│  │                                             │   │
│  │  ┌──────────────────────────────────┐      │   │
│  │  │   Kubernetes VM                  │      │   │
│  │  │                                  │      │   │
│  │  │   - API Server                   │      │   │
│  │  │   - etcd                         │      │   │
│  │  │   - Controller Manager           │      │   │
│  │  │   - Scheduler                    │      │   │
│  │  │   - kubelet                      │      │   │
│  │  │                                  │      │   │
│  │  │   Single-node cluster            │      │   │
│  │  └──────────────────────────────────┘      │   │
│  │                                             │   │
│  │  Tightly integrated with Docker             │   │
│  └────────────────────────────────────────────┘   │
│                      ↑                             │
│              Automatic Networking                  │
└─────────────────────────────────────────────────────┘
```

**Key Points:**
- Integrated with Docker Desktop
- Single-node setup
- Automatic configuration
- Simple on/off toggle
- Good Docker integration

## Networking Architecture

### Port Mapping
```
┌──────────────┐
│  localhost   │
└──────┬───────┘
       │ Port 80, 443
       ↓
┌──────────────────────┐
│  Load Balancer       │
│  (Host Network)      │
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  Service (ClusterIP) │
│  10.96.x.x:80        │
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│  Pod (10.244.x.x:80) │
└──────────────────────┘
```

### Service Types

1. **ClusterIP** (Default)
   - Internal cluster communication only
   - Not accessible from outside

2. **NodePort**
   - Exposes service on each node's IP at a static port
   - Accessible via `<NodeIP>:<NodePort>`

3. **LoadBalancer**
   - Provisions external load balancer
   - k3d: Built-in Traefik
   - Kind: Requires MetalLB or port-forward
   - Minikube: Requires `minikube tunnel`

4. **Ingress**
   - HTTP/HTTPS routing
   - Requires Ingress Controller
   - Path-based and host-based routing

## Storage Architecture

### Persistent Volumes

```
┌─────────────────────────────────────┐
│        macOS Host Filesystem        │
└──────────────┬──────────────────────┘
               │ Volume Mount
               ↓
┌─────────────────────────────────────┐
│     Container/Node Storage          │
└──────────────┬──────────────────────┘
               │ PersistentVolume
               ↓
┌─────────────────────────────────────┐
│   PersistentVolumeClaim (PVC)       │
└──────────────┬──────────────────────┘
               │ Mount
               ↓
┌─────────────────────────────────────┐
│      Pod Container Volume           │
└─────────────────────────────────────┘
```

### Storage Classes

- **Local Path** (Default for most solutions)
  - Uses local filesystem
  - Not shared between nodes
  - Good for development

- **HostPath**
  - Direct mount from host
  - Useful for local development
  - Not portable

## Component Communication

```
┌──────────────┐
│   kubectl    │
│   (CLI)      │
└──────┬───────┘
       │ HTTPS (6443)
       ↓
┌──────────────────────┐
│   API Server         │
│   (Control Plane)    │
└──────┬───────────────┘
       │
       ├───────────────────┐
       │                   │
       ↓                   ↓
┌──────────────┐    ┌──────────────┐
│   etcd       │    │  Scheduler   │
│   (State)    │    │              │
└──────────────┘    └──────────────┘
       │
       ↓
┌──────────────────────┐
│  Controller Manager  │
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│    kubelet           │
│    (Worker Nodes)    │
└──────┬───────────────┘
       │
       ↓
┌──────────────────────┐
│   Container Runtime  │
│   (containerd)       │
└──────────────────────┘
```

## Resource Management

### CPU and Memory Limits

```yaml
resources:
  requests:      # Minimum guaranteed
    cpu: "100m"
    memory: "64Mi"
  limits:        # Maximum allowed
    cpu: "200m"
    memory: "128Mi"
```

### Node Resource Allocation

```
Total Node Resources
├─ System Reserved (Docker, OS)
├─ Kubernetes Components (kubelet, etc.)
└─ Available for Pods
   ├─ Pod 1 (requests + usage)
   ├─ Pod 2 (requests + usage)
   └─ Pod N (requests + usage)
```

## Comparison of Architectures

| Aspect | Kind | k3d | Minikube |
|--------|------|-----|----------|
| Node Model | Multi-container | Multi-container | Single/Multi container |
| K8s Distribution | Full | k3s (lightweight) | Full |
| State Store | etcd | SQLite | etcd |
| Load Balancer | External | Built-in (Traefik) | Tunnel |
| Container Runtime | containerd | containerd | containerd/docker |
| Resource Overhead | Medium | Low | High |
| Isolation | Container-level | Container-level | Container-level |

## Best Practices

### For Production-Like Testing
- Use **Kind** for multi-node scenarios
- Configure realistic resource limits
- Test with network policies
- Simulate failures

### For Development
- Use **k3d** for fast iteration
- Enable local registry
- Use volume mounts for live reload
- Minimize resource allocation

### For Learning
- Use **Minikube** with addons
- Enable dashboard
- Experiment with different features
- Try different storage classes

## Security Considerations

### RBAC (Role-Based Access Control)
```
User/ServiceAccount
    ↓
  Role/ClusterRole
    ↓
  RoleBinding/ClusterRoleBinding
    ↓
  Permissions Granted
```

### Network Policies
```
Pod A (label: frontend)
    ↓ (allowed)
Pod B (label: backend)
    ↓ (allowed)
Pod C (label: database)
    ✗ (denied from frontend)
```

### Pod Security
- Run as non-root user
- Read-only root filesystem
- Drop capabilities
- Security contexts

## Conclusion

Each architecture has trade-offs:
- **Kind**: Best for testing, high fidelity
- **k3d**: Best for development, fast and lightweight
- **Minikube**: Best for learning, full features

Choose based on your specific needs and constraints.

