# Getting Started with ArgoCD Demo

This guide will help you quickly get started with this ArgoCD demonstration project. Follow these steps to set up your environment and deploy your first application.

## Overview

This project demonstrates GitOps principles using ArgoCD on a Kubernetes cluster. The setup includes:

- A local Kubernetes cluster using Kind
- ArgoCD installed via Terraform
- Sample applications deployed through ArgoCD
- Helm charts for application packaging
- Task automation for common operations

## Quick Setup

For the fastest path to a working environment, run these commands:

```bash
# Clone the repository
git clone https://github.com/sean-njela/argocd-demo.git
cd argocd-demo

# Create the Kind cluster and install ArgoCD
task create-cluster
task install-argocd

# Access the ArgoCD UI
task forward-argocd-ui
# In a separate terminal, get the initial admin password
task argocd-init-passwd
```

The ArgoCD UI will be available at [http://localhost:8080](http://localhost:8080).

## Next Steps

After setting up the environment:

1. [Review the prerequisites](prerequisites.md) to ensure your system meets all requirements
2. [Follow the detailed installation guide](installation.md) for a step-by-step setup
3. Deploy your first application with ArgoCD by following the [Application Deployment Guide](../argocd/applications.md)
4. Explore the [Architecture Overview](../architecture/overview.md) to understand the system design

## Project Structure

```
argocd-demo/
├── terraform/           # Terraform files for ArgoCD installation
├── environments/        # Environment-specific configurations
│   ├── dev/             # Development environment
│   │   ├── apps/        # Application manifests
│   │   └── helm/        # Helm charts
├── docs/                # Documentation
└── Taskfile.yml         # Task automation definitions
```

## Common Tasks

| Task | Description |
|------|-------------|
| `task create-cluster` | Creates a Kind cluster for local development |
| `task install-argocd` | Installs ArgoCD using Terraform |
| `task forward-argocd-ui` | Forwards the ArgoCD UI to localhost:8080 |
| `task argocd-init-passwd` | Retrieves the initial admin password |
| `task expose-kubeconfig` | Exports the cluster's kubeconfig |

For a complete list of available tasks, run `task --list-all`.

## Troubleshooting

If you encounter issues during setup:

1. Ensure all [prerequisites](prerequisites.md) are installed
2. Check the ArgoCD documentation for [troubleshooting tips](https://argo-cd.readthedocs.io/en/stable/user-guide/troubleshooting/)
3. Review the [ArgoCD Overview](../argocd/overview.md) for configuration details
