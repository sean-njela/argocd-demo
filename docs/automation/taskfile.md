# Task Runner Automation

This document explains how the Task runner is used to automate common operations in the ArgoCD demonstration project.

## Overview

The project uses [Task](https://taskfile.dev/) (a task runner / build tool) to automate common operations and provide a consistent interface for working with the project. Task is a modern alternative to Make, with a focus on simplicity and ease of use.

## Taskfile Structure

The main task definitions are stored in `Taskfile.yml` at the root of the project:

```yaml
version: '3'
tasks:
  default:
    desc: "Default command"
    cmds:
      - task --list-all

  ports:
    desc: "This is a command list ports in use"
    cmds:
      - ss -tunl

  create-cluster:
    desc: "Create a Kind cluster if it doesn't already exist"
    cmds:
      - kind create cluster -n argocd-demo --image kindest/node:v1.33.1
    status:
      - kind get clusters | grep argocd-demo

  expose-kubeconfig:
    desc: "Expose cluster kubeconfig"
    cmds:
      - cat ~/.kube/config > config-kind-dev.txt
      - echo "Copy config-kind-dev.txt into lens to view your cluster"

  install-argocd:
    desc: "Install or update Argo CD using Terraform"
    dir: terraform
    deps:
      - create-cluster
    cmds:
      - terraform init
      - terraform apply -auto-approve
```

Additional task files, such as `Taskfile.gitflow.yml`, provide specialized functionality.

## Core Tasks

### Cluster Management

| Task | Description |
|------|-------------|
| `task create-cluster` | Creates a Kind cluster for local development |
| `task delete-cluster` | Deletes the Kind cluster |
| `task expose-kubeconfig` | Exports the kubeconfig to a file |

### ArgoCD Management

| Task | Description |
|------|-------------|
| `task install-argocd` | Installs ArgoCD using Terraform |
| `task forward-argocd-ui` | Forwards the ArgoCD UI to localhost:8080 |
| `task argocd-init-passwd` | Retrieves the initial admin password |

### Utility Tasks

| Task | Description |
|------|-------------|
| `task ports` | Lists all in-use ports |
| `task default` | Shows all available tasks |

## GitFlow Tasks

The project includes GitFlow automation in `Taskfile.gitflow.yml`:

```yaml
version: '3'
tasks:
  feature-start:
    desc: "Start a new feature branch"
    cmds:
      - git checkout -b feature/{{.FEATURE_NAME}}
    vars:
      FEATURE_NAME:
        sh: echo "{{.CLI_ARGS}}"

  feature-finish:
    desc: "Finish a feature branch"
    cmds:
      - git checkout main
      - git merge --no-ff feature/{{.FEATURE_NAME}}
      - git branch -d feature/{{.FEATURE_NAME}}
    vars:
      FEATURE_NAME:
        sh: echo "{{.CLI_ARGS}}"
```

These tasks automate Git workflow operations following the GitFlow branching model.

## Task Dependencies

Tasks can depend on other tasks, ensuring prerequisites are met:

```yaml
install-argocd:
  desc: "Install or update Argo CD using Terraform"
  dir: terraform
  deps:
    - create-cluster
  cmds:
    - terraform init
    - terraform apply -auto-approve
```

In this example, `install-argocd` depends on `create-cluster`, ensuring the cluster exists before attempting to install ArgoCD.

## Task Variables

Tasks can use variables for dynamic behavior:

```yaml
feature-start:
  desc: "Start a new feature branch"
  cmds:
    - git checkout -b feature/{{.FEATURE_NAME}}
  vars:
    FEATURE_NAME:
      sh: echo "{{.CLI_ARGS}}"
```

Variables can be:
- Defined inline
- Derived from command-line arguments
- Generated from shell commands
- Set from environment variables

## Task Execution

Tasks are executed using the `task` command:

```bash
# Run the default task
task

# Run a specific task
task create-cluster

# Run a task with arguments
task feature-start my-new-feature
```

## Extending Task Automation

To add new tasks:

1. Edit the appropriate Taskfile (e.g., `Taskfile.yml`)
2. Define the new task with a description and commands
3. Add any dependencies or variables needed
4. Save the file and run `task --list-all` to verify

Example of adding a new task:

```yaml
deploy-app:
  desc: "Deploy a sample application"
  deps:
    - install-argocd
  cmds:
    - kubectl apply -f 0-application.yaml
    - kubectl apply -f 1-application.yaml
```

## Best Practices

1. **Descriptive Names**: Use clear, descriptive names for tasks
2. **Add Descriptions**: Include a description for each task
3. **Use Dependencies**: Define task dependencies explicitly
4. **Idempotent Commands**: Make tasks safe to run multiple times
5. **Status Checks**: Use status checks to avoid unnecessary work
6. **Organize Tasks**: Group related tasks in separate Taskfiles
7. **Document Tasks**: Include task documentation in project docs

## Related Documentation

- [Installation Guide](../quickstart/installation.md)
- [ArgoCD Overview](../argocd/overview.md)
- [Architecture Overview](../architecture/overview.md)
