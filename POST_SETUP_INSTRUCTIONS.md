# Post-Setup Instructions

## What to Do After `./setup.sh`

Your Kubernetes cluster is now running! Here's what to do next.

### Quick Test (1 minute)

```bash
# 1. Deploy demo app
kubectl apply -f examples/demo-app/

# 2. Wait for ready
kubectl wait --for=condition=Ready pods -l app=demo-app --timeout=60s

# 3. Open in browser (for k3d)
open http://localhost

# Or for Kind/Minikube, see examples/demo-app/QUICK_TEST.md
```

### Verify Everything Works

**Option 1: Browser Test**
- Open `http://localhost` (k3d) or use port-forward (Kind/Minikube)
- You should see a "Hello World" page with server information
- Refresh multiple times - you'll see different pod names (load balancing!)

**Option 2: Automated Test**
```bash
./examples/demo-app/test-loadbalancing.sh
```

This script will:
- ✓ Check if demo app is deployed
- ✓ Send 15 requests
- ✓ Show which pods received requests
- ✓ Display visual distribution chart
- ✓ Confirm load balancing is working

### What You'll See

```
╔════════════════════════════════════════════╗
║          Load Distribution Summary         ║
╚════════════════════════════════════════════╝

demo-app-xxxxx-aaaaa: 5 requests (33%) ██████████
demo-app-xxxxx-bbbbb: 5 requests (33%) ██████████
demo-app-xxxxx-ccccc: 5 requests (33%) ██████████

✓ Load balancing is working! Requests distributed across 3 pods
```

### Next Steps

1. **Read the Guides**
   - Quick: `examples/demo-app/QUICK_TEST.md`
   - Detailed: `examples/demo-app/README.md`
   - Complete: `examples/TESTING_GUIDE.md`

2. **Explore Kubernetes**
   ```bash
   kubectl get all -l app=demo-app
   kubectl logs -l app=demo-app
   kubectl describe pod <pod-name>
   kubectl top pods -l app=demo-app
   ```

3. **Scale the App**
   ```bash
   kubectl scale deployment demo-app --replicas=5
   kubectl get pods -l app=demo-app -w
   ```

4. **Clean Up When Done**
   ```bash
   kubectl delete -f examples/demo-app/
   ```

### Troubleshooting

**Can't access the app?**
```bash
# Check service status
kubectl get svc demo-app

# Use port-forward as fallback
kubectl port-forward svc/demo-app 8080:80
# Then: open http://localhost:8080
```

**Pods not starting?**
```bash
kubectl describe pods -l app=demo-app
kubectl get events --sort-by='.lastTimestamp' | tail -10
```

### Success!

If you can access the demo app in your browser, your Kubernetes cluster is fully functional and ready for development!
