# 🏆 And then there was Production...

We will use a python script to freeze the environment until we are ready to deploy to production. In the manual version we will need to add an ignore-tags annotation to everuy app we have deployed which is not ideal.

How the script works:

 1. When ready to deploy, `pause` will create a new branch and add ignore annotations to all apps in the environment. Then create a pull request.
 2. Merging this pull request will freeze the environment.
 3. Then run the script again by stating a source environment and a destination environment to prepare production push. This creates a pullrequest for the production push. 
 4. Merging this pull request will push to production 
 5. Then we run the script to create a pull request to unfreeze the environment.

We seperated the development(kind) terraform config files from the production(EKS) terraform config files. This is to prevent any accidental changes to the production environment.

Create ECRepositories in the AWS console.
Replace the `api_url` and `prefix` with those of the ECR repo in the image-updater.yaml file in the values folder of the prod environment. 

---

Replace docker hub in the `my-argocd-app3.yaml` file with the ECR repo. 


We do not have annotations or CD in production apps. We always have CDel.

To create the production EKS cluster and deploy Argo CD, simply run:

```sh
task ssh-keygen 
```
Then copy the private key to the `0-repo-secret.yaml` file for argocd-image-updater. Then copy the public key to the deploy key section in the github repo. Also make sure to add the slack token to the `0-notifications-secret.yaml` file. Then run the next command. 


First run:

```sh 
task prod
```

This next command is auto automatically run by `task prod` but it is good to know what it does. It is the first step after provisioning the cluster. It gives your local kubernetes config access to the EKS cluster.

```sh
aws eks update-kubeconfig --name prod-demo --region eu-north-1
```

`<env>-<name> -> prod-demo`

Then run this command in the image updater pod shell:

```sh
 aws ecr --region eu-north-1 get-authorization-token --output text --query 'authorizationData[].authorizationToken' | base64 -d
```
If you get any errors restart the pod, and if persistant, double check your configuration.


---

## 📦 Deploying Docker Images

You will need to provide docker with ECR credentials to be able to push to the ECR. the easiest way is to click the repository and click `view push commands`


```sh
aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin {{.ECR}}
```

```sh
docker tag devopssean/zta_demo_app:dev {{.ECR}}/devopssean/zta_demo_app1:1.5.0
docker push {{.ECR}}/devopssean/zta_demo_app1:1.5.0
```

```sh
docker tag devopssean/zta_demo_app:dev {{.ECR}}/devopssean/zta_demo_app2:2.5.0
docker push {{.ECR}}/devopssean/zta_demo_app2:2.5.0
```

## 📦 Applying apps

There are two apps to apply qa `argocd/2-application.yaml` and prod `argocd/3-application.yaml`. After updating an image the `3-application.yaml` will not auto update as there is no annotation for that. So we test the qa first then if satisfied we push to prod.

## ❄️ Freezing script

**Freezing** a development environment means **stopping all new changes**, updates, or features from being added — so you can test, stabilise, and prepare for release without unexpected breakage.

Freezing can be done in many ways. We will no longer use a python script as I want it to be an unopinionated process. We will rather use a `freeze.yaml` file that will be checked by every GH actions job. 
We will also make use of codeowners to protect the freeze being bypassed. So in this process, the dev and qa will have auto deploy enabled while the prod will not. Then when all tests pass and all parties are satisfied we freeze the environments. 

* Lock package versions (`requirements.txt`, `package-lock.json`) 
* Pin Docker base images (`python:3.10.12` not `python:3.10`)

Then we open a PR to change the targetRevision from main to a specific tag and also update the `values.yaml` file of the prod environment. This will trigger a new build and push to production. Then we open a PR to unfreeze the environment. 

```yaml
# ArgoCD Application with frozen Git tag
source:
  repoURL: https://github.com/myorg/gitops-config
  targetRevision: v1.3.0-rc  # <- frozen release tag
  path: apps/myapp
  helm:
    valueFiles:
    - values.yaml

```

> 🧊 You’re telling ArgoCD: “Deploy only this frozen state. No more updates unless we manually change this.”
>

| Freeze Type | What It Stops |
| --- | --- |
| Code Freeze | Merges, commits, PRs |
| Infra Freeze | Terraform/Helm/K8s/ArgoCD changes |
| Dependency Freeze | Lib/package updates |

The deploy job is the only job that checks freeze.yaml all others can run without checking it. 

```sh
[Branches: dev, staging, main]
   |
   |--> CI: build, lint, test (ALWAYS allowed)
   |
   |--> CI: deploy? Check freeze.yaml + branch rules

```

---