# Hello World Example

A simple example to verify your Kubernetes cluster is working correctly.

## What This Deploys

- **Deployment**: 3 replicas of NGINX demo app
- **Service**: LoadBalancer service to expose the app

## Deploy

```bash
# Deploy the application
kubectl apply -f deployment.yaml

# Check status
kubectl get pods
kubectl get services

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods -l app=hello-world --timeout=60s
```

## Access the Application

### For k3d:
```bash
# Service is automatically available on localhost
curl http://localhost:80

# Or in browser: http://localhost
```

### For Kind:
```bash
# Port forward
kubectl port-forward svc/hello-world 8080:80

# Access at http://localhost:8080
```

### For Minikube:
```bash
# Option 1: Tunnel (in separate terminal)
minikube tunnel

# Then access at http://localhost

# Option 2: Port forward
kubectl port-forward svc/hello-world 8080:80

# Access at http://localhost:8080
```

## Scale the Application

```bash
# Scale to 5 replicas
kubectl scale deployment hello-world --replicas=5

# Verify
kubectl get pods
```

## View Logs

```bash
# Logs from all pods
kubectl logs -l app=hello-world

# Logs from specific pod
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>
```

## Update the Application

```bash
# Edit the deployment
kubectl edit deployment hello-world

# Or apply changes to the YAML file
kubectl apply -f deployment.yaml
```

## Clean Up

```bash
# Delete all resources
kubectl delete -f deployment.yaml

# Verify deletion
kubectl get pods
kubectl get services
```

## Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Service not accessible
```bash
# Check service
kubectl describe service hello-world

# Check endpoints
kubectl get endpoints hello-world

# Use port-forward as alternative
kubectl port-forward svc/hello-world 8080:80
```

### Image pull errors
```bash
# If on private network or behind proxy
# The nginx demo image should work without authentication
# But if issues persist, check Docker daemon
docker pull nginxdemos/hello:latest
```

