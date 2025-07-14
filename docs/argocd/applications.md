# Application Deployment with ArgoCD

This document explains how applications are defined, deployed, and managed using ArgoCD in this project.

## Application Definition

In ArgoCD, applications are defined using the `Application` custom resource. This project includes two sample applications:

1. A Helm-based application (`0-application.yaml`)
2. A Kubernetes manifest-based application (`1-application.yaml`)

### Example Application Definition

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myargoapp-0
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/sean-njela/argocd-demo.git
    targetRevision: HEAD
    path: environments/dev/helm/myargoapp-chart
    helm:
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: myapp-0
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Key Components of an Application Definition

### Metadata

- **name**: Unique identifier for the application
- **namespace**: The namespace where the ArgoCD Application resource is created (typically `argocd`)

### Spec

- **project**: The ArgoCD project this application belongs to (default or custom)
- **source**: Where to find the application manifests:
  - **repoURL**: Git repository URL
  - **targetRevision**: Git revision (branch, tag, commit)
  - **path**: Path within the repository
  - **helm**: Helm-specific configuration (if using Helm)
- **destination**: Where to deploy the application:
  - **server**: Target Kubernetes cluster
  - **namespace**: Target namespace for the application
- **syncPolicy**: How ArgoCD should handle synchronization:
  - **automated**: Settings for automatic synchronization
  - **syncOptions**: Additional sync options

## Application Types

### Helm-Based Applications

For applications packaged as Helm charts:

```yaml
source:
  repoURL: https://github.com/sean-njela/argocd-demo.git
  targetRevision: HEAD
  path: environments/dev/helm/myargoapp-chart
  helm:
    valueFiles:
      - values.yaml
    parameters:
      - name: replicaCount
        value: "2"
```

### Kubernetes Manifest Applications

For applications defined with plain Kubernetes manifests:

```yaml
source:
  repoURL: https://github.com/sean-njela/argocd-demo.git
  targetRevision: HEAD
  path: environments/dev/apps/myapp
  directory:
    recurse: true
    jsonnet: {}
```

### Kustomize Applications

For applications using Kustomize:

```yaml
source:
  repoURL: https://github.com/sean-njela/argocd-demo.git
  targetRevision: HEAD
  path: environments/dev/kustomize
  kustomize:
    namePrefix: dev-
    images:
      - myapp:latest
```

## Sync Policies

### Manual Sync

Applications can be configured for manual synchronization:

```yaml
syncPolicy: {}  # No automated sync
```

With manual sync, changes must be applied explicitly through the UI or CLI.

### Automated Sync

For automatic synchronization when changes are detected:

```yaml
syncPolicy:
  automated:
    prune: true    # Remove resources that no longer exist in Git
    selfHeal: true # Revert manual changes made to the cluster
```

### Sync Options

Additional synchronization options:

```yaml
syncPolicy:
  syncOptions:
    - CreateNamespace=true    # Create namespace if it doesn't exist
    - PruneLast=true          # Remove resources last during sync
    - ApplyOutOfSyncOnly=true # Only apply resources that are out of sync
```

## Application Health

ArgoCD monitors the health of deployed applications based on:

1. Kubernetes resource status
2. Custom health checks
3. Resource-specific health assessments (e.g., Deployments, StatefulSets)

Health status is displayed in the UI and available via the API and CLI.

## Deploying Applications

### Using kubectl

```bash
# Apply the Application manifest
kubectl apply -f 0-application.yaml
```

### Using ArgoCD CLI

```bash
# Create application from a manifest
argocd app create -f 0-application.yaml

# Create application with CLI parameters
argocd app create myapp \
  --repo https://github.com/sean-njela/argocd-demo.git \
  --path environments/dev/apps/myapp \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace myapp
```

### Using the ArgoCD UI

1. Navigate to the ArgoCD UI at [http://localhost:8080](http://localhost:8080)
2. Click "New App" in the top left
3. Fill in the application details
4. Click "Create"

## Managing Applications

### Viewing Application Status

```bash
# Using kubectl
kubectl get applications -n argocd
kubectl describe application myapp -n argocd

# Using ArgoCD CLI
argocd app get myapp
argocd app list
```

### Syncing Applications

```bash
# Using ArgoCD CLI
argocd app sync myapp

# Force sync (overwrite live state)
argocd app sync myapp --force
```

### Deleting Applications

```bash
# Using kubectl
kubectl delete application myapp -n argocd

# Using ArgoCD CLI
argocd app delete myapp
```

## Best Practices

1. **Use Declarative Definitions**: Store Application manifests in Git
2. **Environment Separation**: Use separate paths or values for different environments
3. **Resource Limits**: Set appropriate CPU and memory limits
4. **Health Checks**: Implement proper readiness and liveness probes
5. **Namespace Isolation**: Use separate namespaces for different applications
6. **Sync Windows**: Configure sync windows for controlled updates
7. **Progressive Delivery**: Use canary or blue-green deployments for critical applications

## Related Documentation

- [ArgoCD Overview](overview.md)
- [Environment Management](environments.md)
- [System Architecture](../architecture/overview.md)
- [Helm Chart Structure](../helm/structure.md)
