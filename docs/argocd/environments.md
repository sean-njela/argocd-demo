# Environment Management with ArgoCD

This document explains how multiple environments are managed in this ArgoCD project using GitOps principles.

## Environment Structure

The project uses a directory-based approach to manage different environments:

```
environments/
├── dev/                  # Development environment
│   ├── apps/             # Kubernetes manifest applications
│   │   ├── app1/
│   │   └── app2/
│   └── helm/             # Helm chart applications
│       └── myargoapp-chart/
└── README.md             # Environment documentation
```

This structure allows for:
- Clear separation between environments
- Environment-specific configurations
- Consistent application structure across environments
- Easy addition of new environments (staging, production, etc.)

## Environment Configuration

### Development Environment

The development environment (`dev/`) is configured for:

- Local development using Kind
- Rapid iteration and testing
- Minimal resource requirements
- Debug-friendly settings
- Automated synchronization

### Adding New Environments

To add new environments (e.g., staging, production):

1. Create a new directory under `environments/`:
   ```bash
   mkdir -p environments/staging/apps environments/staging/helm
   ```

2. Copy and modify the base configurations:
   ```bash
   cp -r environments/dev/apps/app1 environments/staging/apps/
   ```

3. Update environment-specific values:
   - Resource limits and requests
   - Replica counts
   - Configuration parameters
   - External service endpoints

4. Create environment-specific ArgoCD Applications:
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: myapp-staging
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/sean-njela/argocd-demo.git
       targetRevision: HEAD
       path: environments/staging/apps/app1
     destination:
       server: https://kubernetes.default.svc
       namespace: myapp-staging
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
         - CreateNamespace=true
   ```

## Environment Isolation

Each environment is isolated through:

1. **Namespace Separation**: Each environment uses dedicated namespaces
2. **Configuration Separation**: Environment-specific configurations
3. **Resource Quotas**: Limits on CPU, memory, and other resources
4. **Network Policies**: Controlled network access between environments
5. **RBAC**: Role-based access control for different environments

## Environment-Specific Values

### Helm Values

For Helm-based applications, environment-specific values are managed through values files:

```yaml
# environments/dev/helm/myargoapp-chart/values.yaml
replicaCount: 1
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

```yaml
# environments/staging/helm/myargoapp-chart/values.yaml
replicaCount: 2
resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Kustomize Overlays

For applications using Kustomize, environment-specific configurations are managed through overlays:

```
apps/myapp/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   │   ├── kustomization.yaml
│   │   └── patch.yaml
│   └── staging/
│       ├── kustomization.yaml
│       └── patch.yaml
```

## Promotion Between Environments

The project supports promoting applications between environments:

1. **Testing in Development**: Applications are first deployed to the development environment
2. **Validation**: Automated and manual testing verifies the application
3. **Promotion**: Changes are merged to the staging branch
4. **Staging Deployment**: ArgoCD automatically deploys to staging
5. **Production Approval**: Changes are approved for production
6. **Production Deployment**: ArgoCD deploys to production

## Environment-Specific Sync Policies

Different environments can have different sync policies:

- **Development**: Automated sync with self-healing
  ```yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
  ```

- **Staging**: Automated sync with manual approval
  ```yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - PruneLast=true
  ```

- **Production**: Manual sync with sync windows
  ```yaml
  syncPolicy:
    syncOptions:
      - PruneLast=true
      - ApplyOutOfSyncOnly=true
  ```

## Environment Variables and Secrets

Environment-specific secrets and variables are managed through:

1. **Kubernetes Secrets**: For sensitive information
2. **ConfigMaps**: For non-sensitive configuration
3. **External Secret Management**: Integration with tools like HashiCorp Vault (in production)

## Best Practices

1. **Consistent Structure**: Maintain the same structure across environments
2. **Minimal Differences**: Keep environment-specific changes to a minimum
3. **Documentation**: Document the purpose and configuration of each environment
4. **Testing**: Test changes in lower environments before promotion
5. **Access Control**: Implement appropriate access controls for each environment
6. **Monitoring**: Set up environment-specific monitoring and alerts
7. **Disaster Recovery**: Implement backup and recovery procedures for each environment

## Related Documentation

- [ArgoCD Overview](overview.md)
- [Application Deployment](applications.md)
- [System Architecture](../architecture/overview.md)
- [Infrastructure with Terraform](../infrastructure/terraform.md)
