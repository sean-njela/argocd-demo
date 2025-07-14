# Prerequisites

Before you begin with the ArgoCD demonstration project, ensure your system meets the following requirements.

## Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| [Docker](https://www.docker.com/) | 20.10+ | Container runtime for Kind |
| [Kubernetes](https://kubernetes.io/) | 1.23+ | Container orchestration |
| [Kind](https://kind.sigs.k8s.io/) | 0.14+ | Local Kubernetes cluster |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | 1.23+ | Kubernetes CLI |
| [Terraform](https://www.terraform.io/) | 1.0+ | Infrastructure provisioning |
| [Helm](https://helm.sh/) | 3.8+ | Package management |
| [Task](https://taskfile.dev/) | 3.0+ | Task automation |
| [Git](https://git-scm.com/) | 2.30+ | Version control |

## System Requirements

- **CPU**: 2+ cores recommended
- **Memory**: 4GB+ RAM recommended
- **Disk Space**: 10GB+ free space
- **Operating System**: Linux, macOS, or Windows with WSL2

## Environment Setup

### Docker Configuration

Ensure Docker is properly configured:

```bash
# Verify Docker installation
docker --version

# Ensure Docker daemon is running
docker info
```

### Kubernetes Tools

Verify Kubernetes tools are installed:

```bash
# Verify kubectl installation
kubectl version --client

# Verify Kind installation
kind version

# Verify Helm installation
helm version
```

### Terraform Setup

Ensure Terraform is properly installed:

```bash
# Verify Terraform installation
terraform version
```

### Task Runner

Verify Task runner is installed:

```bash
# Verify Task installation
task --version
```

## Network Requirements

- Outbound internet access for downloading container images
- Available local ports:
  - 8080: ArgoCD UI
  - 6443: Kubernetes API server

## Optional Tools

These tools are not required but can enhance your experience:

- [k9s](https://k9scli.io/): Terminal-based UI for Kubernetes
- [Lens](https://k8slens.dev/): Kubernetes IDE for simplified cluster management
- [kubectx/kubens](https://github.com/ahmetb/kubectx): Tools for switching between contexts and namespaces

## Next Steps

Once you've confirmed all prerequisites are met, proceed to the [Installation Guide](installation.md) to set up the ArgoCD demonstration environment.
