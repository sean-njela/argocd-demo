# Argo CD Image Updater

## Overview

Argo CD Image Updater is a tool that automatically updates container images in your Kubernetes cluster based on the latest available versions in your container registry. It helps keep your applications up to date with the latest security patches and bug fixes.

There are **two *write-back methods*** supported by **Argo CD Image Updater**, which define *where* the image update changes are applied:

---

## 🔄 Argo CD Image Updater: Write-Back Methods

There are **two primary write-back methods**:

---

### 1. **Git Write-Back (GitOps Mode)** ✅

This is the **default and recommended** method, fully aligned with **GitOps principles**.

#### 🛠 How it works:

* Image Updater detects a new image version.
* It **modifies the Kubernetes manifest or Helm values file in the Git repository**.
* Commits and pushes the change to Git.
* Argo CD (which continuously watches Git) detects the change and applies it to the cluster.

#### ✅ Pros:

* Git remains the **source of truth**.
* Full audit history via Git commits.
* Works well with **review processes**, **PRs**, and **version control** tools.
* Clean separation of change and deployment.

#### 🔐 Requirements:

* Access to Git repo with push privileges (via SSH key or token).
* Correct annotations for image list, strategy, and write-back config.

---

### 2. **Direct Cluster Update (Argo CD API Mode)** ⚠️

This is a more **imperative** approach, where the image updater **bypasses Git** and **directly patches the live application in the Kubernetes cluster** via the Argo CD API.

#### 🛠 How it works:

* Detects a new image version.
* Uses the Argo CD API to patch the image parameter of the running app.
* Change is applied directly to the live Kubernetes app (stored in Argo CD’s state), but **not recorded in Git**.

#### ⚠️ Pros:

* Fastest way to update running workloads.
* Doesn’t require Git access.

#### ❌ Cons:

* **Violates GitOps principles** — Git is no longer the single source of truth.
* Changes **will be overwritten** if Argo CD auto-syncs from Git later.
* No Git commit/audit trail of what was deployed.

#### ⚙️ Use case:

* Temporary patches or urgent updates where Git isn’t accessible.
* Testing environments.

---

## 📝 Summary Table

| Method             | Description                      | GitOps-Friendly | Persisted in Git | Recommended For       |
| ------------------ | -------------------------------- | --------------- | ---------------- | --------------------- |
| **Git Write-Back** | Updates manifests in Git         | ✅ Yes           | ✅ Yes            | Production, CI/CD     |
| **Direct Cluster** | Updates Argo CD app live via API | ❌ No            | ❌ No             | Dev/test, emergencies |

---

### 🔧 Configuration

Specify the write-back method via annotations or config file:

```yaml
argocd-image-updater.argoproj.io/write-back-method: git
```

or

```yaml
argocd-image-updater.argoproj.io/write-back-method: argocd
```

---

Next, check out [Argo CD Image Updater Setup](image-updater-setup.md)