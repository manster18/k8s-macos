# Quick Test Guide

Fast track to verify your cluster is working!

## One-Command Deploy

```bash
kubectl apply -f examples/demo-app/ && \
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
# Terminal 1: Port-forward
kubectl port-forward svc/demo-app 8080:80

# Terminal 2: Access
open http://localhost:8080
```

### Minikube
```bash
# Terminal 1: Tunnel
minikube tunnel

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

