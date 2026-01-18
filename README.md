# Nginx Kubernetes Deployment

A production-ready Nginx deployment on Kubernetes with infrastructure as code, CI/CD, and GitOps practices.

## 🎯 Features

- **Terraform Module**: Automated AWS EKS cluster provisioning
- **CI/CD Pipeline**: GitHub Actions for automated build and deployment
- **Kubernetes Manifests**: Best practices including probes, autoscaling, and security
- **GitOps**: Argo CD and Flux CD configurations for declarative deployments

## 📁 Repository Structure

```
.
├── terraform/              # Terraform module for EKS cluster
│   ├── main.tf            # Main Terraform configuration
│   ├── variables.tf       # Input variables
│   ├── outputs.tf         # Output values
│   └── README.md          # Terraform documentation
├── k8s/                   # Kubernetes manifests
│   ├── base/              # Base Kustomize configuration
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   └── kustomization.yaml
│   └── overlays/          # Environment-specific overlays
│       └── production/
│           ├── kustomization.yaml
│           └── deployment-patch.yaml
├── gitops/                # GitOps configurations
│   ├── argocd-application.yaml
│   ├── argocd-application-production.yaml
│   ├── argocd-config.yaml
│   ├── flux-kustomization.yaml
│   └── README.md
├── .github/
│   └── workflows/
│       └── ci-cd.yaml     # GitHub Actions CI/CD pipeline
├── Dockerfile             # Container image definition
└── index.html            # Sample web page
```

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- kubectl
- Docker
- Git

### 1. Provision Kubernetes Cluster

```bash
cd terraform
terraform init
terraform plan
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name nginx-k8s-cluster
```

### 2. Deploy Application

#### Option A: Using kubectl directly
```bash
kubectl apply -k k8s/base
```

#### Option B: Using Argo CD (GitOps)
```bash
# Install Argo CD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Deploy application
kubectl apply -f gitops/argocd-application.yaml
```

#### Option C: Using Flux CD (GitOps)
```bash
# Install Flux
flux bootstrap github \
  --owner=madnemesio \
  --repository=nginx \
  --branch=main \
  --path=./gitops

# Deploy application
kubectl apply -f gitops/flux-kustomization.yaml
```

### 3. Verify Deployment

```bash
# Check pods
kubectl get pods -n nginx-app

# Check service
kubectl get svc -n nginx-app

# Check HPA
kubectl get hpa -n nginx-app

# Access the application
kubectl port-forward svc/nginx-service 8080:80 -n nginx-app
# Visit http://localhost:8080
```

## 🏗️ Infrastructure Details

### Terraform Module

The Terraform module provisions:
- AWS EKS Cluster with managed node groups
- VPC with public and private subnets across multiple AZs
- Security groups and IAM roles
- NAT gateways for private subnet internet access
- Auto-scaling configuration

See [terraform/README.md](terraform/README.md) for detailed documentation.

### Kubernetes Manifests

#### Best Practices Implemented:

1. **Health Probes**
   - Liveness Probe: Ensures container is running
   - Readiness Probe: Ensures container is ready to serve traffic
   - Startup Probe: Handles slow-starting containers

2. **Autoscaling**
   - HorizontalPodAutoscaler with CPU and memory metrics
   - Smart scaling policies (scale up fast, scale down slowly)
   - Min 3, max 10 replicas

3. **Security**
   - Non-root user execution
   - Read-only root filesystem where possible
   - Security context with dropped capabilities
   - Pod Security Standards compliance

4. **Resource Management**
   - Resource requests and limits defined
   - Proper resource allocation for stability

5. **High Availability**
   - Pod anti-affinity for distribution across nodes
   - Multiple replicas

## 🔄 CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Lint Stage**
   - Kubernetes manifest validation
   - Terraform format and validation

2. **Build Stage**
   - Multi-architecture Docker image build (amd64, arm64)
   - Image pushed to GitHub Container Registry
   - Layer caching for faster builds

3. **Security Scan**
   - Trivy vulnerability scanning
   - Results uploaded to GitHub Security

4. **Deploy Stages**
   - Staging deployment (develop branch)
   - Production deployment (main branch)
   - Deployment verification

### Required Secrets

Configure these secrets in GitHub repository settings:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

## 📊 GitOps

### Argo CD

Features:
- Automated synchronization from Git
- Self-healing capabilities
- Web UI for visualization
- Rollback support

See [gitops/README.md](gitops/README.md) for setup instructions.

### Flux CD

Features:
- Lightweight and fast
- Progressive delivery
- Native Kustomize support
- Helm controller

See [gitops/README.md](gitops/README.md) for setup instructions.

## 🔧 Configuration

### Environment Variables

The deployment can be customized using Kustomize overlays:

```bash
# Deploy to production
kubectl apply -k k8s/overlays/production
```

### Scaling

Manually scale the deployment:
```bash
kubectl scale deployment nginx-deployment --replicas=5 -n nginx-app
```

Or let HPA handle it automatically based on metrics.

## 📈 Monitoring

### View Logs
```bash
kubectl logs -f deployment/nginx-deployment -n nginx-app
```

### View Metrics
```bash
kubectl top pods -n nginx-app
kubectl top nodes
```

### Check HPA Status
```bash
kubectl describe hpa nginx-hpa -n nginx-app
```

## 🧪 Testing

### Test Autoscaling
```bash
# Generate load
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://nginx-service.nginx-app; done"

# Watch HPA scale up
kubectl get hpa nginx-hpa -n nginx-app --watch
```

### Test Health Endpoints
```bash
# Port forward to a pod
kubectl port-forward pod/<pod-name> 8080:80 -n nginx-app

# Test health endpoint
curl http://localhost:8080/health
```

## 🛡️ Security

- Container runs as non-root user
- Security context with dropped capabilities
- Network policies can be added
- Secrets should be managed with external-secrets or sealed-secrets
- RBAC policies for service accounts

## 🔄 Updates and Rollbacks

### Rolling Update
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.26-alpine -n nginx-app
kubectl rollout status deployment/nginx-deployment -n nginx-app
```

### Rollback
```bash
kubectl rollout undo deployment/nginx-deployment -n nginx-app
kubectl rollout history deployment/nginx-deployment -n nginx-app
```

## 🧹 Cleanup

### Delete Application
```bash
kubectl delete -k k8s/base
```

### Destroy Infrastructure
```bash
cd terraform
terraform destroy
```

## 📝 Best Practices

1. **Infrastructure as Code**: All infrastructure defined in version control
2. **GitOps**: Single source of truth in Git repository
3. **Automated Testing**: CI pipeline validates changes
4. **Security Scanning**: Automated vulnerability detection
5. **Monitoring**: Health checks and metrics collection
6. **Documentation**: Comprehensive docs for all components

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is open source and available under the MIT License.

## 🆘 Support

For issues and questions:
- Open an issue in the GitHub repository
- Check the documentation in subdirectories
- Review GitHub Actions logs for CI/CD issues

## 🔗 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Argo CD Documentation](https://argo-cd.readthedocs.io/)
- [Flux CD Documentation](https://fluxcd.io/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)