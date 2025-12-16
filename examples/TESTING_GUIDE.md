# Kubernetes Cluster Testing Guide

Complete guide for testing your local Kubernetes cluster after setup.

## Overview

After setting up your cluster with `setup.sh`, follow this guide to deploy and test a demo application.

## Quick Visual Workflow

```
┌─────────────────┐
│  Setup Cluster  │
│  ./setup.sh     │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│ Deploy Demo App │
│ kubectl apply   │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│  Test in        │
│  Browser        │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│ Test Load       │
│ Balancing       │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   Clean Up      │
│ kubectl delete  │
└─────────────────┘
```

## Step-by-Step Instructions

### Step 1: Setup Your Cluster

Choose your preferred solution:

**k3d (Recommended - Fastest)**
```bash
cd k3d
./setup.sh
# Follow the interactive prompts
```

**Kind (Best for multi-node testing)**
```bash
cd kind
./setup.sh
# Follow the interactive prompts
```

**Minikube (Most features)**
```bash
cd minikube
./setup.sh
# Follow the interactive prompts
```

### Step 2: Verify Cluster is Running

```bash
# Check nodes
kubectl get nodes

# Expected output: All nodes should be Ready
# NAME                   STATUS   ROLES    AGE   VERSION
# k3d-k8s-dev-server-0   Ready    master   2m    v1.28.x
# k3d-k8s-dev-agent-0    Ready    <none>   2m    v1.28.x
# k3d-k8s-dev-agent-1    Ready    <none>   2m    v1.28.x
```

### Step 3: Deploy Demo Application

```bash
# From repository root
kubectl apply -f examples/demo-app/

# Wait for pods to be ready
kubectl wait --for=condition=Ready pods -l app=demo-app --timeout=60s
```

### Step 4: Check Deployment Status

```bash
# View all resources
kubectl get all -l app=demo-app

# Expected output:
# NAME                            READY   STATUS    RESTARTS   AGE
# pod/demo-app-xxxxx-xxxxx        1/1     Running   0          30s
# pod/demo-app-xxxxx-xxxxx        1/1     Running   0          30s
# pod/demo-app-xxxxx-xxxxx        1/1     Running   0          30s
#
# NAME               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# service/demo-app   LoadBalancer   10.43.xxx.xxx   localhost     80:xxxxx/TCP   30s
```

### Step 5: Access the Application

#### For k3d:

**Method 1: Direct Access (Easiest)**
```bash
# Open in browser
open http://localhost

# Or use curl
curl http://localhost
```

#### For Kind:

**Method 1: Port Forward**
```bash
# In Terminal 1
kubectl port-forward svc/demo-app 8080:80

# In Terminal 2 or browser
open http://localhost:8080
```

#### For Minikube:

**Method 1: Minikube Tunnel**
```bash
# In Terminal 1
minikube tunnel
# Keep this running

# In Terminal 2 or browser
open http://localhost
```

**Method 2: Port Forward**
```bash
# In Terminal 1
kubectl port-forward svc/demo-app 8080:80

# In Terminal 2 or browser
open http://localhost:8080
```

### Step 6: Test Load Balancing

**Manual Testing:**
```bash
# Send multiple requests and observe different pods responding
for i in {1..10}; do
  echo "Request $i:"
  curl -s http://localhost | grep "Server address"
  sleep 0.5
done
```

**Automated Testing:**
```bash
# Run the load balancing test script
./examples/demo-app/test-loadbalancing.sh
```

Expected output:
```
╔════════════════════════════════════════════╗
║       Demo App Load Balancing Test         ║
╚════════════════════════════════════════════╝

Cluster Status:
  Ready Pods: 3/3

Testing Load Balancing:
Sending 15 requests to observe pod distribution...

Request 1: demo-app-xxxxx-xxxxx (10.42.0.6)
Request 2: demo-app-xxxxx-xxxxx (10.42.1.5)
Request 3: demo-app-xxxxx-xxxxx (10.42.2.4)
...

╔════════════════════════════════════════════╗
║        Load Distribution Summary           ║
╚════════════════════════════════════════════╝

demo-app-xxxxx-xxxxx: 5 requests (33%) ██████████
demo-app-xxxxx-xxxxx: 5 requests (33%) ██████████
demo-app-xxxxx-xxxxx: 5 requests (33%) ██████████

✓ Load balancing is working! Requests distributed across 3 pods
```

### Step 7: Explore the Application

**What You'll See in Browser:**
- Server name (pod name)
- Server address (pod IP)
- Server port
- Request URI
- Request date
- Client information

**Refresh the page multiple times** to see different pods responding!

### Step 8: View Logs

```bash
# View logs from all demo app pods
kubectl logs -l app=demo-app --tail=20

# Follow logs in real-time
kubectl logs -l app=demo-app -f

# View logs from specific pod
kubectl logs <pod-name>
```

### Step 9: Scale the Application

```bash
# Scale up to 5 replicas
kubectl scale deployment demo-app --replicas=5

# Watch pods being created
kubectl get pods -l app=demo-app -w

# Scale back to 3
kubectl scale deployment demo-app --replicas=3
```

### Step 10: Monitor Resources

If metrics-server is installed:

```bash
# View pod resource usage
kubectl top pods -l app=demo-app

# View node resource usage
kubectl top nodes
```

### Step 11: Clean Up

```bash
# Delete all demo resources
kubectl delete -f examples/demo-app/

# Verify deletion
kubectl get all -l app=demo-app
# Should return: No resources found
```

## Advanced Testing

### Test with Ingress (Optional)

```bash
# Deploy ingress
kubectl apply -f examples/demo-app/ingress.yaml

# Add to /etc/hosts
echo "127.0.0.1 demo.local" | sudo tee -a /etc/hosts

# Access via hostname
curl http://demo.local
open http://demo.local

# Clean up
kubectl delete -f examples/demo-app/ingress.yaml
sudo sed -i '' '/demo.local/d' /etc/hosts
```

### Stress Testing

```bash
# Send many requests quickly
for i in {1..100}; do
  curl -s http://localhost > /dev/null &
done

# Monitor pods during load
watch kubectl top pods -l app=demo-app
```

### Test Rolling Updates

```bash
# Update the deployment with a new image
kubectl set image deployment/demo-app nginx=nginxdemos/hello:plain-text

# Watch the rollout
kubectl rollout status deployment/demo-app

# Check rollout history
kubectl rollout history deployment/demo-app

# Rollback if needed
kubectl rollout undo deployment/demo-app
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pods -l app=demo-app

# Check events
kubectl get events --sort-by='.lastTimestamp' | tail -20

# Check node resources
kubectl top nodes
```

### Can't Access Application

```bash
# Verify service
kubectl get svc demo-app

# Check endpoints
kubectl get endpoints demo-app

# Test from within cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- curl http://demo-app

# Force port-forward as fallback
kubectl port-forward svc/demo-app 8080:80
```

### Image Pull Errors

```bash
# Check if image exists locally
docker images | grep hello

# Pull manually
docker pull nginxdemos/hello:latest

# For k3d, import to cluster
k3d image import nginxdemos/hello:latest -c k8s-dev
```

### Load Balancer Issues (k3d)

```bash
# Check svclb pods
kubectl get pods -n kube-system -l svccontroller.k3s.cattle.io/svcname=demo-app

# Check k3d proxy
docker logs k3d-k8s-dev-serverlb
```

## Success Criteria

Your cluster is working correctly if:

- ✓ All pods are in `Running` state
- ✓ Service has `EXTERNAL-IP` assigned
- ✓ You can access the application in browser
- ✓ Multiple requests show different pod names (load balancing)
- ✓ Logs show incoming requests
- ✓ Scaling works correctly
- ✓ Metrics (if installed) show resource usage

## Next Steps

Once the demo app works:

1. **Deploy your own applications**
   - Use the demo app manifests as a template
   - Modify for your needs

2. **Explore Kubernetes features**
   - ConfigMaps and Secrets
   - Persistent Volumes
   - Network Policies
   - RBAC

3. **Try advanced scenarios**
   - Multi-tier applications
   - Databases with persistence
   - CI/CD pipelines
   - Monitoring stacks (Prometheus/Grafana)

## Additional Resources

- **Demo App Details**: `examples/demo-app/README.md`
- **Quick Test**: `examples/demo-app/QUICK_TEST.md`
- **Cluster Comparison**: `docs/COMPARISON.md`
- **Architecture**: `docs/ARCHITECTURE.md`

## Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review logs: `kubectl logs -l app=demo-app`
3. Check events: `kubectl get events`
4. Review cluster-specific README in `k3d/`, `kind/`, or `minikube/`
5. Search GitHub issues for the specific tool

---

**Happy Testing!** If you can successfully access and test the demo app, your Kubernetes cluster is ready for development!

