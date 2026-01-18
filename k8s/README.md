# Kubernetes Manifests

This directory contains Kubernetes manifests for deploying the nginx application.

## Structure

- **base/**: Base Kustomize configuration that can be used across environments
- **overlays/**: Environment-specific configurations that extend the base

## Base Configuration

The base configuration includes:

- **namespace.yaml**: Creates the nginx-app namespace
- **configmap.yaml**: Nginx configuration with health endpoint
- **deployment.yaml**: Nginx deployment with best practices
  - 3 replicas for high availability
  - Liveness, readiness, and startup probes
  - Resource requests and limits
  - Security context (non-root user)
  - Pod anti-affinity rules
- **service.yaml**: LoadBalancer service for external access
- **hpa.yaml**: HorizontalPodAutoscaler for auto-scaling
  - Scales based on CPU (70%) and memory (80%)
  - Min 3, max 10 replicas
  - Smart scaling policies

## Overlays

### Production

The production overlay:
- Increases replica count to 5
- Adjusts resource limits for production workload
- Adds production-specific labels

## Deployment

### Deploy Base Configuration
```bash
kubectl apply -k k8s/base
```

### Deploy Production Configuration
```bash
kubectl apply -k k8s/overlays/production
```

### Verify Deployment
```bash
kubectl get all -n nginx-app
```

## Best Practices Implemented

### 1. Health Checks
- **Liveness Probe**: Checks if container is alive (restarts if failing)
- **Readiness Probe**: Checks if container is ready to serve traffic
- **Startup Probe**: Gives container time to start before other probes kick in

### 2. Resource Management
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
  limits:
    memory: "128Mi"
    cpu: "200m"
```

### 3. Security
- Runs as non-root user (UID 101)
- Drops all capabilities, adds only NET_BIND_SERVICE
- Uses seccomp profile
- Read-only root filesystem where possible

### 4. High Availability
- Multiple replicas
- Pod anti-affinity to spread across nodes
- PodDisruptionBudget can be added for production

### 5. Auto-Scaling
- HPA monitors CPU and memory
- Scales up quickly when needed
- Scales down gradually to avoid flapping

## Customization

### Change Replica Count
Edit the deployment or use kubectl:
```bash
kubectl scale deployment nginx-deployment --replicas=5 -n nginx-app
```

### Update Image
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26-alpine -n nginx-app
```

### Update ConfigMap
Edit `configmap.yaml` and reapply:
```bash
kubectl apply -k k8s/base
kubectl rollout restart deployment/nginx-deployment -n nginx-app
```

## Monitoring

### Check Pod Status
```bash
kubectl get pods -n nginx-app
kubectl describe pod <pod-name> -n nginx-app
```

### View Logs
```bash
kubectl logs -f deployment/nginx-deployment -n nginx-app
```

### Check HPA
```bash
kubectl get hpa -n nginx-app
kubectl describe hpa nginx-hpa -n nginx-app
```

### Check Service
```bash
kubectl get svc nginx-service -n nginx-app
```

## Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n nginx-app
kubectl logs <pod-name> -n nginx-app
```

### Service Not Accessible
```bash
kubectl get endpoints -n nginx-app
kubectl describe svc nginx-service -n nginx-app
```

### HPA Not Scaling
```bash
# Ensure metrics-server is installed
kubectl get deployment metrics-server -n kube-system

# Check HPA status
kubectl describe hpa nginx-hpa -n nginx-app
```

## Adding NetworkPolicy

For additional security, you can add a NetworkPolicy:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: nginx-network-policy
  namespace: nginx-app
spec:
  podSelector:
    matchLabels:
      app: nginx
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 80
  egress:
  - to:
    - namespaceSelector: {}
```

## Next Steps

1. Add Ingress for better routing
2. Configure TLS/SSL certificates
3. Add monitoring with Prometheus
4. Set up logging with EFK stack
5. Implement backup strategies
