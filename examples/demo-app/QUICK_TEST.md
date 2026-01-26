# Quick Test Guide

Fast track to verify your cluster is working!

## One-Command Deploy

**For k3d and Kind:**
```bash
kubectl apply -f examples/demo-app/ && \
kubectl wait --for=condition=Ready pods -l app=demo-app --timeout=60s && \
echo "Demo app is ready!"
```

**For Minikube (LoadBalancer only, no Ingress):**
```bash
kubectl apply -f examples/demo-app/deployment.yaml && \
kubectl apply -f examples/demo-app/service.yaml && \
kubectl wait --for=condition=Ready pods -l app=demo-app --timeout=60s && \
echo "Demo app is ready!"
```

## Access Methods

### k3d (Easiest)
```bash
# Just open in browser
open http://localhost

# Or curl
curl http://localhost
```

### Kind
```bash
# With Ingress (recommended - load balancing works):
open http://localhost
curl http://localhost

# Without Ingress (fallback - single pod):
kubectl port-forward svc/demo-app 8080:80
open http://localhost:8080
```

### Minikube
```bash
# Deploy only deployment and service (NOT ingress.yaml)
kubectl apply -f examples/demo-app/deployment.yaml
kubectl apply -f examples/demo-app/service.yaml

# Terminal 1: Tunnel (requires sudo for port 80!)
sudo minikube tunnel

# Terminal 2: Access
open http://localhost
```

## Test Load Balancing

```bash
./examples/demo-app/test-loadbalancing.sh
```

## Quick Commands

```bash
# Check status
kubectl get all -l app=demo-app

# View logs
kubectl logs -l app=demo-app --tail=10

# Scale
kubectl scale deployment demo-app --replicas=5

# Clean up
kubectl delete -f examples/demo-app/
```

## Troubleshooting

**Can't connect?**
```bash
kubectl get svc demo-app  # Check service status
kubectl get pods -l app=demo-app  # Check pods
kubectl port-forward svc/demo-app 8080:80  # Use port-forward
```

**Pods not ready?**
```bash
kubectl describe pods -l app=demo-app  # Check pod details
kubectl get events --sort-by='.lastTimestamp' | tail -10  # Recent events
```

That's it! Your cluster is working if you can access the demo app.

