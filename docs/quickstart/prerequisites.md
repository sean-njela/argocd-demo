# Prerequisites

This project uses [Devbox](https://www.jetify.com/devbox/) to manage the development environment. Devbox provides a consistent, isolated environment with all the necessary tools pre-installed.


## System Requirements

- **CPU**: 2+ cores recommended
- **Memory**: 4GB+ RAM recommended
- **Disk Space**: 10GB+ free space
- **Operating System**: Linux, macOS, or Windows with WSL2

## Network Requirements

- Outbound internet access for downloading container images
- Available local ports:
  - 8080: ArgoCD UI
  - 6443: Kubernetes API server


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

This concludes all the prerequisites for this project. (Yes, really.)

## Optional Tools

These tools are not required for the project to run but can enhance your experience. They are also included in the devbox environment:

- [k9s](https://k9scli.io/): Terminal-based UI for Kubernetes
- [Lens](https://k8slens.dev/): Kubernetes IDE for simplified cluster management
- [kubectx/kubens](https://github.com/ahmetb/kubectx): Tools for switching between contexts and namespaces

## Next Steps

Once you've confirmed all prerequisites are met, proceed to the [Getting Started](getting-started.md) to set up the ArgoCD demonstration environment.
