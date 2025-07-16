# Task Runner Automation

This document explains how the Task runner is used to automate common operations in the ArgoCD demonstration project.

## Overview

The project uses [Task](https://taskfile.dev/) (a task runner / build tool) to automate common operations and provide a consistent interface for working with the project. Task is a modern alternative to Make, with a focus on simplicity and ease of use.

## Taskfile Structure

The main task definitions are stored in `Taskfile.yml` at the root of the project:

Available tasks:

| Task | Description |
|------|-------------|
| argocd-init-passwd | This is a command to initialize argocd password. Use admin as username |
| bootstrap-app0 | Bootstrap argocd application using app0 |
| cleanup | Deletes the terraform resources and the kind cluster |
| create-cluster | Create a Kind cluster if it doesn't already exist |
| default | Default command |
| del-ssh-key | Delete ssh key for argocd-image-updater |
| dev | Spin up teh complete dev cluster |
| docs | 🌐 Serve docs locally -> http://127.0.0.1:8000/argocd-demo/ |
| expose-kubeconfig | Expose cluster kubeconfig |
| helm-add-argocd | Add argocd helm repo (image updater chart lives here) |
| port-forward-argocd | Forward the Argo CD server UI to localhost:8080 |
| ports | This is a command to list ports in use |
| ssh-keygen | Generate ssh key for argocd-image-updater |
| tf-apply | Install or update Argo CD resources using Terraform |
| tf-lint | Makes sure tf files arecorrectly formatted before running tf commands |


Additional task files, such as `Taskfile.gitflow.yml`, provide repeatable gitflow functionality.

Available gitflow tasks:

| Task | Description |
|------|-------------|
| argocd-init-passwd | This is a command to initialize argocd password. Use admin as username |
| bootstrap-app0 | Bootstrap argocd application using app0 |
| cleanup | Deletes the terraform resources and the kind cluster |
| create-cluster | Create a Kind cluster if it doesn't already exist |
| default | Default command |
| del-ssh-key | Delete ssh key for argocd-image-updater |
| dev | Spin up teh complete dev cluster |
| docs | 🌐 Serve docs locally -> http://127.0.0.1:8000/argocd-demo/ |
| expose-kubeconfig | Expose cluster kubeconfig |
| helm-add-argocd | Add argocd helm repo (image updater chart lives here) |
| port-forward-argocd | Forward the Argo CD server UI to localhost:8080 |
| ports | This is a command to list ports in use |
| ssh-keygen | Generate ssh key for argocd-image-updater |
| tf-apply | Install or update Argo CD resources using Terraform |
| tf-lint | Makes sure tf files arecorrectly formatted before running tf commands |

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

- [ArgoCD Overview](../argocd/overview.md)
- [Architecture Overview](../architecture/overview.md)
