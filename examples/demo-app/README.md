# Demo Application - Quick Start

A simple demo application to verify your Kubernetes cluster is working correctly.

## What This Deploys

- **Application**: NGINX demo app that displays server information
- **Replicas**: 3 pods for load balancing demonstration
- **Service**: LoadBalancer type for easy external access
- **Ingress**: Optional HTTP routing configuration

## Prerequisites

- Running k3d, Kind, or Minikube cluster
- `kubectl` configured and connected to your cluster

## Quick Start

### 1. Deploy the Application

```bash
# From the repository root
kubectl apply -f examples/demo-app/

# Or from this directory
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

### 2. Wait for Pods to be Ready

```bash
kubectl wait --for=condition=Ready pods -l app=demo-app --timeout=60s
```

### 3. Check Deployment Status

```bash
# View all resources
kubectl get all -l app=demo-app

# View detailed pod information
kubectl get pods -l app=demo-app -o wide
```

### 4. Access the Application

#### For k3d:
The LoadBalancer is automatically available on port 80:

```bash
# Open in browser
open http://localhost

# Or use curl
curl http://localhost
```

#### For Kind:

Kind on macOS requires Ingress for external access with load balancing.

**Option 1: Using Ingress (Recommended - with load balancing)**

```bash
# 1. Ensure Ingress Controller is installed (done by setup.sh)
kubectl get pods -n ingress-nginx

# 2. Deploy the application (includes ingress.yaml)
kubectl apply -f examples/demo-app/

# 3. Access via localhost (Ingress handles load balancing)
curl http://localhost
open http://localhost

# Optional: Use custom domain
echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts
curl http://demo.local
open http://demo.local
```

**Option 2: Using port-forward (No load balancing)**

```bash
kubectl port-forward svc/demo-app 8080:80

# Open in browser
open http://localhost:8080

# Note: port-forward connects to a single pod only
```

#### For Minikube:
Use minikube tunnel or port-forward:

```bash
# Option 1: Tunnel (in separate terminal)
minikube tunnel

# Then access
open http://localhost

# Option 2: Port-forward
kubectl port-forward svc/demo-app 8080:80
open http://localhost:8080
```

## What You'll See

The demo page shows:
- Server name (pod name)
- Server address (pod IP)
- Server port
- Request information
- Client address

### About Load Balancing in Browser

**Important Note:** When you refresh the page in your browser, you'll likely see the **same pod** every time. This is **normal behavior**!

**Why?** Browsers use HTTP Keep-Alive connections:
- Your browser maintains one TCP connection
- LoadBalancer routes by TCP connection, not by HTTP request
- All requests over that connection go to the same pod

**How to see different pods:**
1. Close and reopen your browser (new connection)
2. Open in incognito/private mode (separate connection)
3. Try different browsers simultaneously
4. Use the automated test script: `./test-loadbalancing.sh`

**Technical Details:**
```
Browser Keep-Alive:
  Request 1 → [Same TCP Connection] → Pod-A
  Request 2 → [Same TCP Connection] → Pod-A
  Request 3 → [Same TCP Connection] → Pod-A

Curl (script):
  Request 1 → [New TCP Connection] → Pod-A
  Request 2 → [New TCP Connection] → Pod-B
  Request 3 → [New TCP Connection] → Pod-C
```

This is how L4 (TCP) load balancing works - it's connection-based, not request-based!

## Testing Load Balancing

```bash
# Send multiple requests and see different pods responding
for i in {1..10}; do 
  echo "Request $i:"; 
  curl -s http://localhost | grep "Server address"; 
  sleep 0.5; 
done
```

## View Logs

```bash
# Logs from all pods
kubectl logs -l app=demo-app --tail=20

# Follow logs in real-time
kubectl logs -l app=demo-app -f

# Logs from specific pod
kubectl logs <pod-name>
```

## Scale the Application

```bash
# Scale to 5 replicas
kubectl scale deployment demo-app --replicas=5

# Verify
kubectl get pods -l app=demo-app

# Scale back to 3
kubectl scale deployment demo-app --replicas=3
```

## Ingress Configuration

The Ingress resource is automatically deployed with `kubectl apply -f examples/demo-app/`.

**Features:**
- Default route: accessible via `http://localhost`
- Custom domain: accessible via `http://demo.local` (requires /etc/hosts entry)
- Load balancing across all pods

**For custom domain access:**

```bash
# Add to /etc/hosts (requires sudo)
echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts

# Access via hostname
curl http://demo.local
open http://demo.local
```

**Note:** Ingress requires an Ingress Controller (nginx-ingress recommended for Kind).

## Monitor Resources

If metrics-server is installed:

```bash
# Pod resource usage
kubectl top pods -l app=demo-app

# Node resource usage
kubectl top nodes
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl describe pods -l app=demo-app

# Check events
kubectl get events --sort-by='.lastTimestamp' | tail -20
```

### Can't access the application

**For Kind with Ingress:**
```bash
# 1. Check Ingress Controller is running
kubectl get pods -n ingress-nginx

# 2. Check Ingress resource
kubectl get ingress demo-app
kubectl describe ingress demo-app

# 3. Check service and endpoints
kubectl get svc demo-app
kubectl get endpoints demo-app

# 4. Test if ingress is working
curl -v http://localhost

# 5. Fallback: Use port-forward
kubectl port-forward svc/demo-app 8080:80
curl http://localhost:8080
```

**For other clusters:**
```bash
# Check service
kubectl get svc demo-app

# Check endpoints
kubectl get endpoints demo-app

# Use port-forward as fallback
kubectl port-forward svc/demo-app 8080:80
```

### Load balancing not working (seeing only one pod)

**For Kind users:**
- If using port-forward: This is expected - port-forward connects to ONE pod
- Solution: Use Ingress for true load balancing (see Kind setup instructions)

**For browser users (any cluster):**
- Browsers reuse HTTP connections (Keep-Alive), showing the same pod
- This is normal HTTP behavior, not a Kubernetes issue
- Use test script to verify: `bash examples/demo-app/test-loadbalancing.sh`
- See `LOAD_BALANCING_EXPLAINED.md` for details

### Image pull errors

```bash
# The nginx demo image should work without authentication
# If issues persist, check:
docker pull nginxdemos/hello:latest

# Check pod events
kubectl describe pod <pod-name>
```

## Clean Up

```bash
# Delete all demo resources
kubectl delete -f examples/demo-app/

# Or delete individually
kubectl delete deployment demo-app
kubectl delete service demo-app
kubectl delete ingress demo-app  # if created

# Verify deletion
kubectl get all -l app=demo-app
```

## Next Steps

1. Modify `deployment.yaml` to change replica count
2. Try different `service` types (ClusterIP, NodePort)
3. Experiment with resource limits
4. Add ConfigMaps or Secrets
5. Deploy your own application

## Understanding Load Balancing Behavior

**Important:** See `LOAD_BALANCING_EXPLAINED.md` for detailed explanation of why your browser shows the same pod while the test script shows different pods. TL;DR: This is normal and correct L4 (TCP) load balancing behavior!

## Learn More

- [Kubernetes Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Kubernetes Services](https://kubernetes.io/docs/concepts/services-networking/service/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Load Balancing Explained](./LOAD_BALANCING_EXPLAINED.md) - Why browser shows same pod

