# Helm Chart Structure

This document explains the structure and organization of Helm charts used in the ArgoCD demonstration project.

## Overview

Helm is a package manager for Kubernetes that allows you to define, install, and upgrade complex Kubernetes applications. This project uses Helm charts to package applications for deployment through ArgoCD.

## Chart Location

Helm charts in this project are stored in the environment-specific directories:

```
environments/
└── dev/
    └── helm/
        └── myargoapp-chart/
            ├── Chart.yaml
            ├── values.yaml
            ├── templates/
            │   ├── deployment.yaml
            │   ├── service.yaml
            │   └── _helpers.tpl
            └── README.md
```

## Standard Chart Structure

A Helm chart follows this standard structure:

```
myargoapp-chart/
├── Chart.yaml           # Metadata about the chart
├── values.yaml          # Default configuration values
├── templates/           # Templated Kubernetes YAML files
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl     # Reusable template snippets
├── charts/              # Dependencies (optional)
└── README.md            # Documentation
```

## Key Components

### Chart.yaml

The `Chart.yaml` file contains metadata about the chart:

```yaml
apiVersion: v2
name: myargoapp-chart
description: A Helm chart for deploying the MyArgoApp application
type: application
version: 0.1.0
appVersion: "1.0.0"
```

Key fields:
- **apiVersion**: Helm API version (v2 for Helm 3)
- **name**: Name of the chart
- **description**: Description of the chart
- **type**: Type of chart (application or library)
- **version**: Chart version
- **appVersion**: Application version

### values.yaml

The `values.yaml` file contains default configuration values:

```yaml
replicaCount: 1

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: "1.21.0"

service:
  type: ClusterIP
  port: 80

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi
```

These values can be overridden at deployment time.

### Templates

The `templates/` directory contains Kubernetes manifest templates:

#### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myargoapp-chart.fullname" . }}
  labels:
    {{- include "myargoapp-chart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "myargoapp-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myargoapp-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

#### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "myargoapp-chart.fullname" . }}
  labels:
    {{- include "myargoapp-chart.labels" . | nindent 4 }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    {{- include "myargoapp-chart.selectorLabels" . | nindent 4 }}
```

#### _helpers.tpl

Helper templates provide reusable snippets:

```yaml
{{/* Generate basic labels */}}
{{- define "myargoapp-chart.labels" -}}
helm.sh/chart: {{ include "myargoapp-chart.chart" . }}
{{ include "myargoapp-chart.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/* Selector labels */}}
{{- define "myargoapp-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "myargoapp-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
```

## ArgoCD Integration

ArgoCD can deploy Helm charts in two ways:

1. **Helm Chart Repository**: ArgoCD pulls the chart from a Helm repository
2. **Git Repository**: ArgoCD uses the chart directly from Git

This project uses the Git repository approach, with ArgoCD configured to use the chart from the project repository:

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
```

## Chart Dependencies

Charts can depend on other charts, defined in the `Chart.yaml` file:

```yaml
dependencies:
  - name: postgresql
    version: 10.3.11
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

Dependencies are stored in the `charts/` directory after running:

```bash
helm dependency update
```

## Environment-Specific Values

Different environments can use the same chart with different values:

```
environments/
├── dev/
│   └── helm/
│       └── myargoapp-chart/
│           └── values.yaml  # Development values
└── prod/
    └── helm/
        └── myargoapp-chart/
            └── values.yaml  # Production values
```

## Best Practices

1. **Version Control**: Keep charts in version control
2. **Documentation**: Document chart purpose and values
3. **Validation**: Validate templates with `helm lint` and `helm template`
4. **Reusable Helpers**: Use helper templates for common patterns
5. **Default Values**: Provide sensible defaults in `values.yaml`
6. **Resource Limits**: Always specify resource requests and limits
7. **Labels and Annotations**: Use consistent labeling
8. **Security Context**: Define security contexts for containers
9. **Health Checks**: Include readiness and liveness probes
10. **Versioning**: Update chart version when making changes

## Related Documentation

- [Application Deployment](../argocd/applications.md)
- [ArgoCD Overview](../argocd/overview.md)
- [System Architecture](../architecture/overview.md)
