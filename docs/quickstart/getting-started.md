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

To create the local Kubernetes cluster and deploy Argo CD, simply run:

```sh
task dev
```

This single command will:
1.  Create a local Kind cluster (if it's not already running).
2.  Deploy Argo CD using the Terraform configuration.
3.  Bootstrap argocd application using 0-application.yaml (this is the application.yaml file with app of apps pattern, TF and helm).
4.  Expose cluster kubeconfig for tools like lens
5.  Add argocd helm repo

Then in two seperate terminal windows run:

```sh
task docs # This will serve the docs locally at http://127.0.0.1:8000/argocd-demo/
```

And

```sh
task port-forward-argocd # This will forward the Argo CD server UI to localhost:8080
```

You can now access the Argo CD UI at http://localhost:8080 with username `admin` and for the password run:

```sh
task argocd-init-passwd
```

Use the following command to clean up the cluster and terraform resources:

```sh
task cleanup
```
This will delete the cluster and terraform resources.

#### Other Available Commands

> To see a full list of all available tasks, run `task --list-all`

### Git Workflow with Git Flow

The `Taskfile.gitflow.yml` provides a structured Git workflow using Git Flow. This helps in managing features, releases, and hotfixes in a standardized way.

> use `task -t Taskfile.gitflow.yml --list-all` to see all gitflow tasks

## Troubleshooting

If you encounter issues during setup:

1. Ensure all [prerequisites](prerequisites.md) are installed
2. Check the ArgoCD documentation for [troubleshooting tips](https://argo-cd.readthedocs.io/en/stable/user-guide/troubleshooting/)
3. Review the [ArgoCD Overview](../argocd/overview.md) for configuration details
