# Image Updater Setup


Instead of using CLI helm commands, to setup the image updater, we will use a more repeatable IAC solution.


We will use terraform to install the image updater. (same as we did for argocd)


An ssh key is required for the image updater to work. We will also give it write access to the git repo as we will want to experiement with both git write back methods. This allows the image updater to update the git infra repo with the new image tags.


!!! tip "Delete the key after experiementation is done"
    Since this is a public repo, the key should be deleted after experiementation is done.


Whether we are using private or public docker repos it is the same process. But we will need to provide the image updater with the credentials to access the private repo. 

We will be using helm charts in this project, although it is possible to use raw k8s manifests or Kustomize, we will use helm charts as it is what I am most comfortable with.

We will show how to use git repositories in a gitops workflow as well as using helm repositories directly.


!!!note "The approach is the same when using private docker repos"
    We will need to provide the deployment with the credentials to access the private docker repo, because without it will not be able to pull the image. (read only token is best practice). Then run:
    ```yaml
    kubectl create secret docker-registry dockerconfigjson -n argocd --docker-server=docker.io/v1/ --docker-username=devopssean --docker-password=<your_read_only_token> --docker-email=sean-njela@yahoo.com
    ```
    The updater also needs to access the private repo. So we add the secret name (name: dockerconfigjson) to our deployment manifest (under spec-template-spec-ImagePullSecrets), and we also need to change the image registry in the manifests to point to the private docker repo. ArgoCD Image updater supports multiple registries. So we create and apply a docker secret for our token(`0-docker-secret.yaml`) in the argocd namespace. We will then need to add the following to the values file in the terraform `0-image-updater.yaml` file:
    ```yaml
    config:
      registries:
        - name: dockerhub
          api_url: https://registry-1.docker.io
          ping: yes
          credentials: secret:argocd/dockerhub-token#my-token
          limit: 20 # Rate limit
          default: true # Or we can use annotations in each application to specify the registry to use.
    ```
    Then `tf apply`
--- 

We replaced the https repoURL with an SSH repoURL in the my-argocd-app0.yaml file as argocd-image-updater will be using a key to access and push the new image to the repo.

```yaml
repoURL: ssh://git@github.com/sean-njela/argocd-demo.git
```

---

## Annotations

using an annotation, we define the list of container images that should be automatically updated in a Kubernetes deployment managed by Argo CD. Its value is a comma-separated list of image names (and optionally tags or configuration options).

Example:
```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: myapp=myregistry.io/myapp,sidecar=nginx
```
This example tells Argo CD Image Updater to:

- Track the myregistry.io/myapp image and label it as myapp.
- Track the nginx image and label it as sidecar.

Each of these labels corresponds to container names in the Kubernetes deployment spec.

🔍 Why?
Argo CD Image Updater needs to know which container in your Deployment to update. It uses the key in the image-list annotation (like myapp) to map to a container name inside your Kubernetes resource.

Example:
Suppose your deployment looks like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  template:
    spec:
      containers:
        - name: myapp
          image: myregistry.io/myapp:v0.4.1
```
Then you would configure Argo CD Image Updater like this:

```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: myapp=myregistry.io/myapp:~1.0
```

Here’s what happens:

- `myapp` in the annotation matches the name: `myapp` container in the Deployment.
- Argo CD Image Updater checks for new tags (like v0.4.2) and updates the image if one is available.
- The update is done in the Git repo (if using GitOps) or live, depending on your configuration.

❌ If They Don't Match?
If the annotation says:

```yaml
argocd-image-updater.argoproj.io/image-list: wrongname=myregistry.io/myapp
```
...but the container in the Deployment is named `myapp`, nothing will be updated. Argo CD Image Updater will log a warning like:

```sh
Could not find container with name 'wrongname' in workload ...
```

TL;DR

The key (myapp) must match a container name in the manifest.

It tells Argo CD Image Updater exactly which container to update.

--- 


In our case:

```yaml
annotations:
    argocd-image-updater.argoproj.io/image-list: argocd-app=docker.io/devopssean/zta_demo_app:1.x
```
You can also add other annotations to fine-tune the behavior:

```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: argocd-app=docker.io/devopssean/zta_demo_app:1.x
  argocd-image-updater.argoproj.io/argocd-app.update-strategy: semver
  argocd-image-updater.argoproj.io/write-back-method: git
```

This annotation is essential when you want Argo CD Image Updater to:

- Monitor specific container images.
- Automatically update the Argo CD Application when a new version is available (based on your strategy).

`argocd-app=nanajanashia/argocd-app`:
Tells Argo CD Image Updater to track the image nanajanashia/argocd-app and associate it with the container named argocd-app.

`update-strategy: semver`:
Instructs the updater to sort and evaluate available tags using semantic versioning rules (e.g., 1.0.1 < 1.0.2 < 1.1.0).

`allow-tags: ^1` Allows only tags that:

- Are greater than or equal to 1.0.0
- Are less than 2.0.0

This includes:

- 1.0.0, 1.1.5, 1.9.99

This excludes:

- 2.0.0, 0.9.9, latest, or non-semver tags

`write-back-method: git` Ensures changes are committed back to the Git repo (true GitOps behavior).


!!! warning "If your tags do start with v (e.g., v1.0.0)"
    Then semver strategy will not match those by default. You would need to either:

    - Strip the v from your tag format at the registry level, or

    - Switch to update-strategy: latest and use a regex:

    ```yaml
    argocd-image-updater.argoproj.io/myapp.update-strategy: latest
    argocd-image-updater.argoproj.io/myapp.allow-tags: regexp:^v1\.[0-9]+\.[0-9]+$
    ```
---

You also need to tell Argo CD Image Updater where in the values.yaml file the image and tag are located.

You must add:

```yaml
argocd-image-updater.argoproj.io/myapp.helm-image-tag-spec: image.tag
argocd-image-updater.argoproj.io/myapp.helm-image-name-spec: image.repository
```
These are required when you're not using inline Helm parameters:.

Final Correct Version (when using a values file):
```yaml
annotations:
  argocd-image-updater.argoproj.io/image-list: argocd-app=docker.io/devopssean/zta_demo_app:1.x
  argocd-image-updater.argoproj.io/argocd-app.update-strategy: semver
  argocd-image-updater.argoproj.io/argocd-app.helm-image-tag-spec: image.tag
  argocd-image-updater.argoproj.io/argocd-app.helm-image-name-spec: image.repository
  argocd-image-updater.argoproj.io/write-back-method: git
```

Why this matters:
If you don’t include those helm-image-* annotations, Argo CD Image Updater has no way of knowing what to modify inside your values.yaml.

And your values.yaml should look like:

```yaml
image:
  repository: docker.io/devopssean/zta_demo_app
  tag: "1.0.0"
```

## Sealed Secrets

In the first instance we used a k8s secret manifest with the ssh private key to access the git repo. But later we will use sealed secrets to store the private key. 

The secret should be applied first before bootstrapping argocd.

---