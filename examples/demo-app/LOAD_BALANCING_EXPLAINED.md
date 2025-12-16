# Load Balancing Behavior Explained

## Why Does My Browser Always Show the Same Pod?

This is a common question, and the answer helps understand how Kubernetes load balancing works!

## The Behavior

**In Browser:**
- Refresh page multiple times → Same pod responds
- Looks like load balancing isn't working

**In Test Script:**
- Run `./test-loadbalancing.sh` → Different pods respond
- Load balancing clearly works!

## The Explanation

### How Browsers Work

Browsers use **HTTP Keep-Alive** (persistent connections):

```
┌──────────┐
│ Browser  │
└─────┬────┘
      │ Opens ONE TCP connection
      │ Keeps it open for multiple requests
      ↓
┌─────────────────┐
│  LoadBalancer   │ ← Routes based on TCP connection
└─────┬───────────┘
      │ Connection goes to one pod
      ↓
┌─────────────┐
│   Pod-1     │ ← ALL your browser requests
└─────────────┘
```

**Why?**
- HTTP Keep-Alive is efficient (reuses connections)
- LoadBalancer works at Layer 4 (TCP), not Layer 7 (HTTP)
- Once TCP connection is established, it stays with one pod

### How Curl Works (in our script)

Each curl command creates a **new TCP connection**:

```
Request 1: curl → New Connection → LoadBalancer → Pod-1
Request 2: curl → New Connection → LoadBalancer → Pod-2  
Request 3: curl → New Connection → LoadBalancer → Pod-3
```

## This is CORRECT Behavior!

Your cluster is working perfectly. This is how L4 (Layer 4) load balancing works:

- **Connection-based balancing** (what you have)
  - New connections distributed across pods
  - Existing connections stay with same pod
  - More efficient, better performance

- **Request-based balancing** (requires L7/HTTP load balancer)
  - Every HTTP request can go to different pod
  - Requires parsing HTTP headers (slower)
  - Breaks some applications that need session persistence

## How to See Load Balancing in Action

### Method 1: Close and Reopen Browser

```bash
# 1. Open http://localhost - note the pod name
# 2. Close browser completely
# 3. Reopen http://localhost - likely different pod!
```

### Method 2: Multiple Browser Windows

```bash
# Open in multiple browsers/incognito windows simultaneously:
open -a "Google Chrome" http://localhost
open -a "Safari" http://localhost
open -a "Firefox" http://localhost

# Each browser = separate connection = potentially different pod
```

### Method 3: Use Curl (New Connection Each Time)

```bash
for i in {1..10}; do
  echo "Request $i:"
  curl -s http://localhost | grep "Server name" 
  sleep 0.5
done
```

### Method 4: Automated Test Script

```bash
./test-loadbalancing.sh
```

## Technical Deep Dive

### Layer 4 vs Layer 7 Load Balancing

**Layer 4 (TCP) - What k3s/Kind/Minikube use:**
```
[Client] → [TCP Connection] → [LoadBalancer] → [Pod]
         ↓
   Connection stays with same pod
   Fast and efficient
```

**Layer 7 (HTTP) - Requires Ingress Controller:**
```
[Client] → [HTTP Requests] → [Ingress] → [Different Pods]
         ↓
   Each request can go to different pod
   Slower but more flexible
```

### What Happens Step-by-Step

1. **Browser connects:**
   ```
   Browser → SYN → LoadBalancer
   LoadBalancer → SYN-ACK (routes to Pod-1)
   TCP Connection established with Pod-1
   ```

2. **Browser sends requests:**
   ```
   GET / HTTP/1.1 → [Existing Connection] → Pod-1
   GET / HTTP/1.1 → [Same Connection] → Pod-1
   GET / HTTP/1.1 → [Same Connection] → Pod-1
   ```

3. **Connection stays open:**
   ```
   Browser: Connection: keep-alive
   Pod: Keeps connection open
   All subsequent requests use same connection
   ```

4. **New connection (curl):**
   ```
   curl → New SYN → LoadBalancer
   LoadBalancer → Routes to Pod-2 (round-robin)
   New request goes to different pod
   ```

### Verification

Check LoadBalancer behavior:

```bash
# Show service type
kubectl get svc demo-app

# Show session affinity (should be None)
kubectl get svc demo-app -o jsonpath='{.spec.sessionAffinity}'

# Show endpoints (all pods)
kubectl get endpoints demo-app
```

## When Would You Want Request-Based Balancing?

Use an **Ingress Controller** if you need:

1. **Path-based routing**
   ```
   /api/* → backend-pods
   /web/* → frontend-pods
   ```

2. **Header-based routing**
   ```
   X-Version: v2 → new-version-pods
   ```

3. **True request-level balancing**
   ```
   Every HTTP request → potentially different pod
   ```

### Example with Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-app
spec:
  rules:
  - http:
      paths:
      - path: /
        backend:
          service:
            name: demo-app
            port: 80
```

This adds L7 (HTTP) load balancing on top of L4.

## Summary

| Scenario | Connection Type | Pod Selection | Normal? |
|----------|----------------|---------------|---------|
| Browser refresh | Persistent (Keep-Alive) | Same pod | Yes |
| New browser window | New connection | Possibly different | Yes |
| Curl in loop | New connection each time | Different pods | Yes |
| Test script | New connection each time | Balanced across pods | Yes |

## Conclusion

Your load balancer **is working correctly**! The behavior you see in the browser is:

**Expected** - HTTP Keep-Alive is standard  
**Efficient** - Connection reuse is good  
**Correct** - L4 load balancing works this way  

To see load balancing in action, use:
- The test script: `./test-loadbalancing.sh`
- Multiple browser windows/sessions
- Curl in a loop

Your Kubernetes cluster is functioning perfectly!
