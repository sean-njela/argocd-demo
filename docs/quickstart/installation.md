# Installation Guide

This guide provides detailed instructions for setting up the ArgoCD demonstration environment from scratch.

## Step 1: Clone the Repository

Start by cloning the repository to your local machine:

```bash
git clone https://github.com/sean-njela/argocd-demo.git
cd argocd-demo
```

## Step 2: Create a Kubernetes Cluster

The project uses Kind (Kubernetes in Docker) to create a local Kubernetes cluster:

```bash
# Create a Kind cluster named argocd-demo
task create-cluster
```

This command creates a Kubernetes cluster using Kind with the following specifications:
- Cluster name: `argocd-demo`
- Kubernetes version: v1.33.1
- Single node configuration

You can verify the cluster is running with:

```bash
kind get clusters
kubectl cluster-info --context kind-argocd-demo
```

## Step 3: Install ArgoCD

ArgoCD is installed using Terraform to ensure reproducible infrastructure:

```bash
# Install ArgoCD using Terraform
task install-argocd
```

This command:
1. Initializes Terraform in the `terraform/` directory
2. Applies the Terraform configuration to install ArgoCD
3. Creates the ArgoCD namespace
4. Deploys ArgoCD using the Helm chart (version 3.35.4)
5. Configures ArgoCD with values from `terraform/values/argocd-values.yaml`

## Step 4: Access the ArgoCD UI

To access the ArgoCD web interface:

```bash
# Forward the ArgoCD server to localhost:8080
task forward-argocd-ui
```

The ArgoCD UI will be available at [http://localhost:8080](http://localhost:8080).

To retrieve the initial admin password:

```bash
# Get the initial admin password
task argocd-init-passwd
```

Login with:
- Username: `admin`
- Password: (output from the command above)

## Step 5: Deploy Sample Applications

The project includes sample applications that can be deployed to demonstrate ArgoCD's capabilities:

```bash
# Apply the Application manifests
kubectl apply -f 0-application.yaml
kubectl apply -f 1-application.yaml
```

These manifests define ArgoCD Applications that point to:
- `0-application.yaml`: A Helm-based application
- `1-application.yaml`: A Kubernetes manifest-based application

## Step 6: Export Kubeconfig (Optional)

If you want to use external tools like Lens to manage your cluster:

```bash
# Export the kubeconfig to a file
task expose-kubeconfig
```

This creates a `config-kind-dev.txt` file that can be imported into Kubernetes management tools.

## Verification

Verify that all components are running correctly:

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check ArgoCD applications
kubectl get applications -n argocd
```

## Next Steps

After completing the installation:

1. Explore the [ArgoCD UI](http://localhost:8080) to see the deployed applications
2. Review the [ArgoCD Overview](../argocd/overview.md) to understand the components
3. Learn about [Application Deployment](../argocd/applications.md) with ArgoCD
4. Explore the [Environment Management](../argocd/environments.md) structure

## Troubleshooting

If you encounter issues during installation:

- **Cluster Creation Fails**: Ensure Docker is running and has sufficient resources
- **Terraform Errors**: Check the Terraform logs in the `terraform/` directory
- **ArgoCD UI Not Accessible**: Verify the port forwarding is active and no other service is using port 8080
- **Application Sync Issues**: Check the Application status in the ArgoCD UI or with `kubectl get applications -n argocd`

For more detailed troubleshooting, refer to the [ArgoCD official documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/troubleshooting/).
