# Task Runner Automation

This document explains how the Task runner is used to automate common operations in the ArgoCD demonstration project.

## Overview

The project uses [Task](https://taskfile.dev/) (a task runner / build tool) to automate common operations and provide a consistent interface for working with the project. Task is a modern alternative to Make, with a focus on simplicity and ease of use.

## Taskfile Structure

The main task definitions are stored in `Taskfile.yml` at the root of the project.
Additional task files, such as `Taskfile.gitflow.yml`, provide repeatable gitflow functionality (optional).

Available tasks:

| Task | Description |
|------|-------------|
|----------------- MAIN ----------------|
| argocd-init-passwd-dev | This is a command to initialize argocd password. Use admin as username |
| argocd-init-passwd-prod | This is a command to initialize argocd password. Use admin as username |
| bootstrap-app0-dev | Bootstrap argocd application using app0 |
| bootstrap-app2-prod | Bootstrap argocd application using app2 |
| bootstrap-app3-prod | Bootstrap argocd application using app3 |
| bootstrap-notifications-cm-dev | Bootstrap argocd notifications configmap |
| bootstrap-notifications-cm-prod | Bootstrap argocd notifications configmap |
| bootstrap-notifications-secret-dev | Bootstrap argocd notifications secret |
| bootstrap-notifications-secret-prod | Bootstrap argocd notifications secret |
| bootstrap-sealed-secret-dev | Bootstrap sealed image updater secret |
| bootstrap-sealed-secret-prod | Bootstrap sealed image updater secret |
| cleanup-dev | Deletes the terraform resources and the dev kind cluster |
| cleanup-prod | Deletes the terraform resources and the prod kind cluster |
| commit | 📝 Add and commit changes -> task commit msg="your commit message" |
| create-cluster-dev | Create a Kind cluster if it doesn't already exist |
| create-cluster-prod | Create a Kind cluster if it doesn't already exist |
| default | Default command |
| del-ssh-key | Delete ssh key for argocd-image-updater |
| dev | Spin up the complete dev cluster |
| docker-push-dev | Tag and push docker image -> task docker-tag-push version="1.2.0" |
| docs | 🌐 Serve docs locally -> http://127.0.0.1:8000/argocd-demo/
| ecr-push-prod1 | Tag and push docker image to ECR1 |
| ecr-push-prod2 | Tag and push docker image to ECR2 |
| expose-kubeconfig | Expose cluster kubeconfig |
| helm-add-all | Add all helm repos |
| helm-dry-run | Dry run helm chart to check if it will install successfully |
| helm-package-push | Package and push helm chart to chartmuseum |
| init | ⚙️ Initialize Git Flow with 'main' and 'develop' |
| kubeseal | Encrypt a secret using kubeseal |
| port-fwd-argocd-dev | Forward the Argo CD server UI to localhost:8080 |
| port-fwd-argocd-prod | Forward the Argo CD server UI to localhost:8080 |
| port-fwd-chartmuseum | Forward the Chartmuseum server UI to localhost:8083 |
| ports | This is a command to list ports in use |
| prod | Spin up the complete prod cluster |
| rm-cached | 🧹 Remove cached files |
| ssh-keygen | Generate ssh key for argocd-image-updater |
|----------------- GITFLOW ------------ | 
| sync | 🔄 Sync current branch with latest 'develop' and handle main updates |
| tf-apply-dev | Install or update Argo CD resources using Terraform |
| tf-apply-prod | Install or update Argo CD resources using Terraform for prod env |
| clean:branches | 🧼 Delete all local feature, release, hotfix branches (after merge) |
| feature:clean | 🧹 Delete the current local feature branch after PR merge |
| feature:push | 🚀 Push current feature to origin |
| feature:start | 🚀 Start a new feature from 'develop' -> task feature:start name=login-form |
| hotfix:finish | 🏁 Finish hotfix, tag and merge -> task hotfix:finish version=1.2.1 |
| hotfix:start | 🔥 Start a hotfix from main -> task hotfix:start version=1.2.1 |
| release:finish | 🏁 Finishes and publishes a release (merges, tags, pushes). -> task release:finish version=1.2.0 |
| release:repair | 🛠️ Repairs a broken release:finish (after a failed conflict) -> task release:repair version=1.2.3 |
| release:start | 🚀 Start a new release from develop -> task release:start version=1.2.0 |
| release:verify | ✅ Verifies and prepares 'main' and 'develop' for release -> task release:verify version=1.2.3 |


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
