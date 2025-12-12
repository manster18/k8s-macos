# Kubernetes on macOS - Local Development Environment

This repository contains scripts, configurations, and documentation for running Kubernetes clusters locally on macOS.

## Project Goals

- Provide easy-to-use solutions for running Kubernetes locally on macOS
- Support multi-node cluster configurations
- Enable rapid development and testing of Kubernetes applications
- Compare different local Kubernetes solutions

## Available Solutions

### 1. **Kind (Kubernetes in Docker)** - Recommended for Multi-Node
Kind runs Kubernetes clusters inside Docker containers as nodes. Perfect for multi-node testing.

**Pros:**
- Native multi-node support
- Fast cluster creation (~1-2 minutes)
- Excellent for CI/CD pipelines
- Uses Docker, no additional VM overhead
- Great for testing cluster upgrades

**Cons:**
- Requires Docker Desktop
- Limited LoadBalancer support without additional tools

### 2. **k3d (k3s in Docker)** - Recommended for Speed
Lightweight Kubernetes distribution (k3s) running in Docker containers.

**Pros:**
- Extremely fast startup (<30 seconds)
- Very lightweight (lower resource usage)
- Built-in LoadBalancer support
- Multi-node support
- Great for development

**Cons:**
- Uses k3s (not full Kubernetes, but 99% compatible)
- Some enterprise features missing

### 3. **Minikube** - Classic Choice
The original local Kubernetes solution, mature and feature-rich.

**Pros:**
- Most mature solution
- Multiple driver options (Docker, HyperKit, VirtualBox)
- Rich addon ecosystem
- Good documentation
- Multi-node support (since v1.10.1)

**Cons:**
- Slower startup time
- Higher resource usage
- Single-node by default

### 4. **Docker Desktop Kubernetes**
Built-in Kubernetes support in Docker Desktop.

**Pros:**
- Zero additional setup
- Simple to enable
- Good integration with Docker
- Stable and reliable

**Cons:**
- Single-node only
- Less control over configuration
- Tied to Docker Desktop

### 5. **Rancher Desktop**
Open-source alternative to Docker Desktop with built-in Kubernetes.

**Pros:**
- Free and open-source
- Supports both k3s and regular Kubernetes
- No licensing concerns
- Active development

**Cons:**
- Relatively newer
- Smaller community
- Single-node setup

## Comparison Table

| Solution | Startup Time | Multi-Node | Resource Usage | Best For |
|----------|--------------|------------|----------------|----------|
| **Kind** | ~1-2 min | Yes (Excellent) | Medium | Multi-node testing, CI/CD |
| **k3d** | ~30 sec | Yes (Excellent) | Low | Fast development cycles |
| **Minikube** | ~2-3 min | Yes (Good) | High | Full K8s features, addons |
| **Docker Desktop** | ~1 min | No (Single-node) | Medium | Simple projects |
| **Rancher Desktop** | ~1-2 min | No (Single-node) | Medium | Docker Desktop alternative |

## Repository Structure

```
k8s_macos/
├── kind/               # Kind configurations and scripts
├── k3d/                # k3d configurations and scripts
├── minikube/           # Minikube configurations and scripts
├── common/             # Common scripts and utilities
├── examples/           # Example applications and manifests
├── docs/               # Additional documentation
└── README.md           # This file
```

## Prerequisites

- macOS 11.0 or later
- [Homebrew](https://brew.sh/) package manager
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Rancher Desktop](https://rancherdesktop.io/)
- At least 8GB RAM (16GB recommended for multi-node clusters)
- 20GB free disk space

## Quick Start

Installation commands for each solution will be added in respective directories.

## Documentation

Detailed guides for each solution are available in the `docs/` directory.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - see LICENSE file for details

## Useful Resources

- [Kubernetes Official Documentation](https://kubernetes.io/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [k3d Documentation](https://k3d.io/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/)

---

**Note:** Your development journey with Kubernetes on macOS starts here!

