# GitOps Configuration

This directory contains GitOps configurations for deploying the nginx application using either Argo CD or Flux CD.

## Argo CD

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

### Installation

1. **Install Argo CD**
   ```bash
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```

2. **Access Argo CD UI**
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

3. **Get Admin Password**
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

### Deploying the Application

#### Base Environment
```bash
kubectl apply -f gitops/argocd-application.yaml
```

#### Production Environment
```bash
kubectl apply -f gitops/argocd-application-production.yaml
```

### Features

- **Automated Sync**: Automatically syncs changes from Git repository
- **Self-Healing**: Automatically reverts manual changes to maintain desired state
- **Pruning**: Removes resources that are no longer defined in Git
- **Retry Logic**: Automatically retries failed sync operations

### Monitoring

View application status:
```bash
kubectl get application -n argocd
```

Check sync status:
```bash
kubectl describe application nginx-app -n argocd
```

## Flux CD

Flux CD is a GitOps toolkit for keeping Kubernetes clusters in sync with configuration sources.

### Installation

1. **Install Flux CLI**
   ```bash
   curl -s https://fluxcd.io/install.sh | sudo bash
   ```

2. **Bootstrap Flux**
   ```bash
   flux bootstrap github \
     --owner=madnemesio \
     --repository=nginx \
     --branch=main \
     --path=./gitops \
     --personal
   ```

### Deploying the Application

```bash
kubectl apply -f gitops/flux-kustomization.yaml
```

### Features

- **Source Controller**: Manages Git repositories and artifacts
- **Kustomize Controller**: Applies Kustomize overlays
- **Health Checks**: Monitors deployment health
- **Automatic Reconciliation**: Syncs changes every 5 minutes

### Monitoring

View GitRepository status:
```bash
kubectl get gitrepository -n flux-system
```

View Kustomization status:
```bash
kubectl get kustomization -n flux-system
```

Check reconciliation:
```bash
flux reconcile kustomization nginx-app
```

## Choosing Between Argo CD and Flux

### Use Argo CD if:
- You want a comprehensive UI for visualization
- You need multi-cluster management
- You prefer an application-centric approach

### Use Flux if:
- You prefer a lightweight, CLI-focused approach
- You need advanced Helm controller capabilities
- You want better integration with cloud-native ecosystems

## Best Practices

1. **Branch Strategy**: Use separate branches for different environments
2. **PR Workflow**: Require pull requests for all changes
3. **Automated Testing**: Run tests before merging to main branch
4. **Rollback Strategy**: Keep revision history for easy rollbacks
5. **Monitoring**: Set up alerts for sync failures
6. **Secrets Management**: Use sealed-secrets or external-secrets for sensitive data

## Troubleshooting

### Argo CD

Check application health:
```bash
argocd app get nginx-app
```

Sync manually:
```bash
argocd app sync nginx-app
```

### Flux

Check reconciliation errors:
```bash
flux logs --all-namespaces
```

Force reconciliation:
```bash
flux reconcile source git nginx-repo
flux reconcile kustomization nginx-app
```

## Security Considerations

1. Use RBAC to control access to GitOps tools
2. Enable SSO for authentication
3. Use webhooks for faster sync instead of polling
4. Implement branch protection rules
5. Use signed commits for added security
