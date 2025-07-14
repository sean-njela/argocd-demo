<div align="center">

  <img src="assets/argocd.png" alt="logo" width="200" height="auto" />
  <h1>Argo CD Personal Project</h1>
  
  <p>
    A professional portfolio project showcasing GitOps implementation with Argo CD, Kubernetes, and Infrastructure as Code. This project demonstrates DevOps best practices using modern tools and techniques.

    The project uses Terraform to provision Argo CD into a Kind cluster, implements the App of Apps pattern, and leverages Helm charts for application deployment.
  </p>
  
<p>
  <a href="https://github.com/sean-njela/argocd-demo/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/sean-njela/argocd-demo" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/sean-njela/argocd-demo" alt="last update" />
  </a>
  <a href="https://github.com/sean-njela/argocd-demo/network/members">
    <img src="https://img.shields.io/github/forks/sean-njela/argocd-demo" alt="forks" />
  </a>
  <a href="https://github.com/sean-njela/argocd-demo/stargazers">
    <img src="https://img.shields.io/github/stars/sean-njela/argocd-demo" alt="stars" />
  </a>
  <a href="https://github.com/sean-njela/argocd-demo/issues/">
    <img src="https://img.shields.io/github/issues/sean-njela/argocd-demo" alt="open issues" />
  </a>
  <a href="https://github.com/sean-njela/argocd-demo/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/sean-njela/argocd-demo.svg" alt="license" />
  </a>
</p>

</div>

<br />

## Table of Contents

  * [Screenshots](#screenshots)
  * [Tech Stack](#tech-stack)
  * [Features](#features)
  * [Prerequisites](#prerequisites)
  * [Usage](#usage)
  * [Roadmap](#roadmap)
  * [License](#license)
  * [Contact](#contact)

## Screenshots

<div align="center"> 
  <img src="assets/screenshot2.png" alt="argocd_image_updater"/>
  <img src="assets/argocd_apps_page.webp" alt="argocd_apps_page"/>
</div>

## Tech Stack

![ArgoCD](https://img.shields.io/badge/ArgoCD-2.10.0-green)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27.0-green)
![Docker](https://img.shields.io/badge/Docker-20.10.17-green)
![Devbox](https://img.shields.io/badge/Devbox-0.15.0-green)
![Taskfile](https://img.shields.io/badge/Taskfile-3.44.0-green)
![gitflow](https://img.shields.io/badge/gitflow-1.12-green)
![kubectl](https://img.shields.io/badge/kubectl-1.33-green)
![yq](https://img.shields.io/badge/yq-3.4-green)
![jq](https://img.shields.io/badge/jq-1.8-green)
![yamllint](https://img.shields.io/badge/yamllint-1.37-green)
![helm](https://img.shields.io/badge/helm-3.18-green)
![terraform](https://img.shields.io/badge/terraform-1.12-green)
![k9s](https://img.shields.io/badge/k9s-0.50-green)
![kind](https://img.shields.io/badge/kind-0.29-green)
![kubectx](https://img.shields.io/badge/kubectx-0.9-green)

## Features

- Argo CD for Continuous delivery for Kubernetes applications
- Terraform for Infrastructure as Code
- Taskfiles for repeatable tasks

## Prerequisites

This project uses [Devbox](https://www.jetify.com/devbox/) to manage the development environment. Devbox provides a consistent, isolated environment with all the necessary tools pre-installed.

### Required Tools

0. **install Docker**
   - Follow the [installation instructions](https://docs.docker.com/get-docker/) for your operating system

> The rest of the tools are installed using devbox

1. **Install Devbox**
   - Follow the [installation instructions](https://www.jetify.com/devbox/docs/installing_devbox/) for your operating system

2. **Clone the Repository**
   ```bash
   git clone https://github.com/sean-njela/argocd-demo.git
   cd argocd-demo
   ```

3. **Start the Devbox Environment and poetry environment**
   ```bash
   devbox shell # Start the devbox environment
   poetry install # Install dependencies
   poetry env activate # use the output to activate the poetry environment
   mkdocs serve # Start the mkdocs server http://127.0.0.1:8000/argocd-demo/
   ```
> Note - The first time you run `devbox shell`, it will take a few minutes to install the necessary tools. But after that it will be much faster.

## Usage

This project is designed for a simple, one-command setup. All necessary actions are orchestrated through `Taskfile.yml`.

There are 2 application.yaml files:

1. `0-application.yaml` - This is the application.yaml file with app of apps pattern, TF and helm.
2. `1-application.yaml` - This is the application.yaml file *WITHOUT* app of apps pattern, TF and helm.


#### 🚀 Quick Start

To create the local Kubernetes cluster and deploy Argo CD, simply run:

```sh
task install-argocd
```

This single command will:
1.  Create a local Kind cluster (if it's not already running).
2.  Deploy Argo CD using the Terraform configuration.

#### Other Available Commands

-   **`task forward-argocd-ui`**: Forwards the Argo CD server UI to `localhost:8080`.
-   **`task argocd-init-passwd`**: Retrieves the initial admin password for the Argo CD UI.
-   **`task expose-kubeconfig`**: Exports the cluster's kubeconfig to a file (`config-kind-dev.txt`) for use with tools like Lens.
-   **`task ports`**: Lists all in-use ports.

> To see a full list of all available tasks, run `task --list-all`

### Git Workflow with Git Flow

The `Taskfile.gitflow.yml` provides a structured Git workflow using Git Flow. This helps in managing features, releases, and hotfixes in a standardized way.

- **`task gitflow:init`**: Initializes Git Flow for the repository.
- **`task gitflow:feature:start name=<feature-name>`**: Starts a new feature branch.
- **`task gitflow:feature:push`**: Pushes the current feature branch to the remote repository.
- **`task gitflow:feature:clean`**: Deletes the local feature branch after it has been merged.
- **`task gitflow:release:start version=<version>`**: Starts a new release branch.
- **`task gitflow:release:finish version=<version>`**: Finishes a release, which merges the release branch into `main` and `develop`, and tags the release.
- **`task gitflow:hotfix:start version=<version>`**: Starts a new hotfix branch.
- **`task gitflow:hotfix:finish version=<version>`**: Finishes a hotfix.

> use `task -t Taskfile.gitflow.yml --list-all` to see all gitflow tasks

### Kubernetes Manifests

The `environments/dev/k8s` directory contains the Kubernetes manifests for the sample application:

- **`deployment.yml`**: Defines the deployment for the application.
- **`service.yml`**: Defines the service to expose the application.


## Roadmap
* [x] ArgoCD implementation
* [x] Terraform infrastructure as code
* [x] Helm chart integration
* [x] App of apps pattern
* [x] Comprehensive documentation
* [ ] ArgoCD Image Updater
* [ ] Deployment freezing
* [ ] Notification system

## NOTES
- The `1-application.yaml` file is the same as the `0-application.yaml` it is the file we used initially before we added the app of apps pattern, tf and helm
- We number the files because we will be adding more and more files in the future

## Documentation

Comprehensive documentation is available in the `docs/` directory. You can view it locally by running:

```bash
mkdocs serve # make sure you are in the poetry environment (check prerequisites)
```

Then navigate to [http://127.0.0.1:8000/argocd-demo/](http://127.0.0.1:8000/argocd-demo/)

The documentation covers:
- Project architecture
- ArgoCD implementation details
- Application deployment process
- Environment management
- Terraform infrastructure
- Helm chart structure
- Automation with Task runner

## Contributors

<a href="https://github.com/sean-njela/argocd-demo/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=sean-njela/argocd-demo" />
</a>

> Contributions are always welcome!

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Sean Njela - [X/twitter](https://x.com/devopssean) - [email](mailto:seannjela@gmail.com)

Project Link: [https://github.com/sean-njela/argocd-demo](https://github.com/sean-njela/argocd-demo)