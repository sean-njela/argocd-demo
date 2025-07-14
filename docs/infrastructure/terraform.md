# Terraform Configuration

This document details the Terraform infrastructure as code implementation used to provision and manage ArgoCD in the Kubernetes cluster.

## Overview

Terraform is used in this project to provide a reproducible, version-controlled approach to infrastructure provisioning. The primary focus is on installing and configuring ArgoCD in the Kubernetes cluster.

## Directory Structure

```
terraform/
├── 0-provider.tf       # Provider configuration
├── 1-argocd.tf         # ArgoCD installation
├── values/             # Helm chart values
│   └── argocd-values.yaml  # ArgoCD configuration values
├── .terraform/         # Terraform state directory (gitignored)
├── terraform.tfstate   # Terraform state file
└── .terraform.lock.hcl # Dependency lock file
```

## Provider Configuration

The project uses the Kubernetes and Helm providers to interact with the Kind cluster:

```hcl
# From 0-provider.tf
provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "kind-argocd-demo"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "kind-argocd-demo"
  }
}
```

## ArgoCD Installation

ArgoCD is installed using the official Helm chart through Terraform:

```hcl
# From 1-argocd.tf
resource "helm_release" "argocd" {
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    version = "3.35.4"
    namespace = "argocd"
    create_namespace = true
    values = [file("values/argocd-values.yaml")]
}
```

This approach offers several benefits:
- **Version Pinning**: Specific ArgoCD version (3.35.4) ensures consistency
- **Namespace Management**: Creates the ArgoCD namespace if it doesn't exist
- **Configuration as Code**: Uses values file for customization
- **Reproducibility**: Same installation can be reproduced on any cluster

## Helm Chart Values

The ArgoCD Helm chart is configured using values specified in `values/argocd-values.yaml`. Key configurations include:

- Server configuration
- RBAC settings
- Resource limits
- High availability settings (disabled for demo)
- UI customization
- Authentication settings

## Execution Flow

When running `task install-argocd`, the following happens:

1. Task runner executes commands in the terraform directory
2. Terraform initializes providers and modules
3. Terraform applies the configuration:
   - Creates the ArgoCD namespace
   - Installs ArgoCD using the Helm chart
   - Applies custom configuration values

## Alternative Approaches

While Terraform is used in this project, the documentation notes alternative approaches that could be used:

```
# Direct kubectl approach
kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Direct Helm approach
helm repo add argocd https://argoproj.github.io/argo-helm
helm repo update
helm install argocd -n argocd --create-namespace argocd/argo-cd --version 3.35.4
```

Terraform was chosen for this project because:
- It provides better dependency management
- Configuration is more maintainable as code
- It integrates well with the GitOps workflow
- It allows for more complex provisioning logic

## Best Practices Implemented

1. **Version Pinning**: Specific versions for providers and charts
2. **Modular Structure**: Separate files for different concerns
3. **Value Externalization**: Configuration values in separate files
4. **Resource Naming**: Consistent naming conventions
5. **State Management**: Proper handling of Terraform state

## Extending the Infrastructure

To extend the infrastructure:

1. Add new `.tf` files for additional components
2. Update or create values files for configuration
3. Apply changes using `terraform apply` or through the task runner

## Related Documentation

- [ArgoCD Overview](../argocd/overview.md)
- [System Architecture](../architecture/overview.md)
- [Getting Started](../quickstart/getting-started.md)
