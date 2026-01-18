# Terraform Kubernetes Module

This Terraform module provisions an AWS EKS (Elastic Kubernetes Service) cluster with all necessary networking components.

## Features

- **AWS EKS Cluster**: Fully managed Kubernetes cluster
- **VPC Configuration**: Private and public subnets across multiple availability zones
- **Managed Node Groups**: Auto-scaling worker nodes with configurable instance types
- **Security**: IRSA (IAM Roles for Service Accounts) enabled
- **High Availability**: Multi-AZ deployment with NAT gateways

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- kubectl installed (for cluster access)

## Usage

### Basic Usage

```hcl
module "kubernetes_cluster" {
  source = "./terraform"

  cluster_name       = "my-nginx-cluster"
  aws_region         = "us-west-2"
  environment        = "production"
  kubernetes_version = "1.28"
}
```

### Custom Configuration

```hcl
module "kubernetes_cluster" {
  source = "./terraform"

  cluster_name       = "nginx-prod-cluster"
  aws_region         = "us-east-1"
  environment        = "production"
  kubernetes_version = "1.28"
  
  # Node configuration
  instance_type  = "t3.large"
  node_count     = 5
  min_node_count = 3
  max_node_count = 10
  
  # Network configuration
  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  
  tags = {
    Project     = "nginx"
    Environment = "production"
    Team        = "platform"
  }
}
```

## Deployment Steps

1. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

2. **Plan the deployment**
   ```bash
   terraform plan
   ```

3. **Apply the configuration**
   ```bash
   terraform apply
   ```

4. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```

5. **Verify cluster access**
   ```bash
   kubectl get nodes
   ```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | AWS region where the cluster will be deployed | `string` | `us-west-2` | no |
| cluster_name | Name of the EKS cluster | `string` | `nginx-k8s-cluster` | no |
| kubernetes_version | Kubernetes version to use | `string` | `1.28` | no |
| environment | Environment name | `string` | `production` | no |
| instance_type | EC2 instance type for worker nodes | `string` | `t3.medium` | no |
| node_count | Desired number of worker nodes | `number` | `3` | no |
| min_node_count | Minimum number of worker nodes | `number` | `2` | no |
| max_node_count | Maximum number of worker nodes | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | Name of the EKS cluster |
| cluster_endpoint | Endpoint for EKS cluster |
| cluster_security_group_id | Security group ID attached to the EKS cluster |
| vpc_id | ID of the VPC |
| configure_kubectl | Command to configure kubectl |

## Cost Optimization

For development environments:
- Set `environment = "dev"` to use a single NAT gateway
- Use smaller instance types (e.g., `t3.small`)
- Reduce node count

## Clean Up

To destroy all resources:
```bash
terraform destroy
```

## Support

For issues and questions, please refer to the main repository README.
