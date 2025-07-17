## Using a helm repo

Using a helm repo is the same as using a git repo. In this case we will use [ChartMuseum](https://github.com/helm/chartmuseum) as a helm repo to store our helm charts.

!!! tip "Reminder"
    You can use the helm show values command to see the values that you can edit in a helm chart. But first, you must add the repository to your helm repo list and update. For example:
    ```bash
    helm repo add argocd https://argoproj.github.io/argo-helm
    helm repo update
    helm show values argocd/argocd-image-updater --version 0.1.0 > show-argo-values.yaml
    ```

We will also add a terraform resource `3-chartmuseum.tf` to provision and manage the chartmuseum instance (this is where we can state the values to override in the values directory). 

Inorder to upload our chart we will need to package it first. Then use curl with binary data to upload the chart to the chartmuseum instance.:

---

## What is helm package?

Helm package is a command that packages a chart directory (containing Chart.yaml, templates/, etc.) into a .tgz archive file.

### 📁 Default Working Directory

By default, `helm package <chart-path>` writes the .tgz file to your current working directory.

```sh
helm package ./mychart
```

This will produce a file like ./mychart-0.1.0.tgz.

### 🗂️ Changing the Output Destination

You can override the default output location using the `-d`, `--destination <dir>` flag, which tells Helm to place the generated archive into the directory you specify:

```sh
helm package ./mychart -d ./output-charts/
```

This will produce a file like ./output-charts/mychart-0.1.0.tgz.

### 🗂️ Changing the Output Destination

You can override the default output location using the `-d`, `--destination <dir>` flag, which tells Helm to place the generated archive into the directory you specify :

```sh
helm package ./mychart -d ./output-charts/
```

This will produce a file like ./output-charts/mychart-0.1.0.tgz. There are many reasons to use the `--destination` flag:

- 📦 1. Organization and Cleanup
By default, Helm writes the .tgz to your current directory (.).
Using --destination ./charts/ keeps your project root clean and groups all chart archives in one place 

- 🛠️ 2. CI/CD and Automation
    In automated pipelines, you’ll often:

        - Generate artifacts into a build directory (e.g., build/ or dist/)
        - Package multiple charts into structured folders
        - Push the resulting .tgz files to artifact storage
    Changing the destination helps integrate chart packaging into the rest of your build/deployment process.

- 🗂️ 3. Multiple Chart Outputs

    If you package several charts in one go (helm package ./chartA ./chartB), --destination ensures they all land in a shared output folder, instead of cluttering various locations.

- 🧩 4. Chart Repositories

    When hosting your own Helm repo (via helm repo index), you’ll want all .tgz files in a single directory. Using --destination is essential to aggregate them before indexing them

---

## Walkthrough

In our case:

```bash
helm package ./environments/dev/helm/myargoapp-chart -d ./packaged-charts/
```
Then 

```bash
curl --data-binary @"./packaged-charts/my-argocd-app-0.1.0.tgz" http://localhost:8083/api/charts
```
You should get a JSON response like:

```json
{"saved": true}
```

!!!warning "Important"
    The output package will be named after the name in the Chart.yaml not the chart directory.

!!! tip "Key point"
    The `@` before the file path is essential! Without it, curl sends the filename as literal data, not the contents of the file Make sure to wrap the file path in quotes, especially if it contains special characters or spaces. ChartMuseum’s API endpoint `/api/charts` expects the raw binary of the .tgz file 

To verify that the chart was uploaded successfully, you can use the following command:

```bash
helm repo add my-uploaded-chart http://localhost:8083
helm repo update
helm search repo my-uploaded-chart
```

Or

```bash
curl http://localhost:8083/api/charts
```

Or 

```bash
curl http://localhost:8083/api/charts/my-argocd-app
```

 
## Connecting to Argo CD

We will connect a seperate application `my-argocd-app2.yaml` to pull from the chartmuseum instance. We will use the same annotation and the same docker image. But we will replace the git source repoURL with the chartmuseum repoURL. Instead of specifying the git branch we will specify the version (targetrevision) of our uploaded chart. We will also use the chart name instead of path.  

Old:

```yaml
spec:
  source:
    repoURL: ssh://git@github.com/sean-njela/argocd-demo.git
    targetRevision: main # branch to deploy from (or HEAD for latest commit)
    path: environments/dev/helm/myargoapp-chart # path to the helm chart (app0)
```

New:

```yaml
spec:
  source:
    repoURL: http://chartmuseum.chartmuseum.svc.cluster.local:8080
    targetRevision: 0.1.0
    chart: my-argocd-app # chart name in Chart.yaml
```
!!! tip "Key point"
    🧠 http://chartmuseum.chartmuseum.svc.cluster.local is a Kubernetes internal DNS name that points to the ChartMuseum service.

    It breaks down like this:

    |Part|Meaning|
    |---|---|
    |chartmuseum|The Service name|
    |chartmuseum (again)|The Namespace where the Service lives|
    |svc|Short for “Service”|
    |cluster.local|Default internal DNS domain of the cluster|
    |8080|Port number (avoids DNS lookup issues when pulling from chartmuseum)|

    ✅ This format allows other pods (like Argo CD) to access the ChartMuseum service inside the cluster without needing external IPs or port-forwarding.

We then apply the app of apps again. But the code must be pushed first.

To push a new version just change the version in the Chart.yaml file and in the `helm-package-push` task and then run the following command:

```bash
task helm-package-push
```

---

## Argo CD Chart Sync Behavior

❌ By default:
Argo CD pulls the version defined in your Application manifest.

It does not auto-upgrade when a new version is pushed to ChartMuseum.

For example, in your Application.yaml (or values in UI), you might have:

```yaml
source:
  repoURL: http://chartmuseum.chartmuseum.svc.cluster.local
  chart: my-argocd-app # chart name in Chart.yaml
  targetRevision: 0.1.0  # 👈 Argo CD will stick to this version
```
Even if you push 0.1.1, Argo CD will stay on 0.1.0 unless told otherwise.

### Options to Automatically Use the New Version

 1. Use `targetRevision: latest`
    This tells Argo CD to always use the newest available chart version:

```yaml
source:
  chart: my-argocd-app  # chart name in Chart.yaml
  targetRevision: latest
```

!!!warning
    Be cautious — this means every new chart version will be picked up automatically, which can be risky in production.

 2. Manually update the version
    
    You can:

    - Edit the Application in the Argo CD UI to change targetRevision
    - Or update your Git manifest and let Argo CD sync it

    This is a manual promotion, which gives you better control.

 3. Automate via CI/CD
    Use a script or pipeline step to:

    - Bump Chart.yaml
    - Push to ChartMuseum
    - Update your Argo CD Application manifest (targetRevision)
    - Commit and push to Git

Argo CD sees the Git change and syncs automatically.

For images we already setup argocd-image-updater to automatically update the image tag in the values.yaml file. 