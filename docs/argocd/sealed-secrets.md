## Sealed Secrets

Sealed Secrets allow us to store our secrets in git and it allows us to encrypt sensitive data in your Kubernetes cluster. 

In our case we will use [Sealed Secrets Controller](https://github.com/Bitnami-Labs/sealed-secrets) to encrypt our secrets.


We will use the public key to encrypt our secrets and controller will use its private key to decrypt the secrets.

---

## Walkthrough

Just as we always do when adding helm charts to our cluster, we add a terrfaorm resource to provision and manage the sealed secrets controller. (`4-sealed-secrets.tf`) Then `tf apply`. We will provision the sealed secrets controller in the `kube-system` namespace. It will be essential for the `kubeseal` CLI tool.

```hcl
resource "helm_release" "sealed-secrets" {
    repository = "https://charts.bitnami.com/bitnami"
    name = "sealed-secrets"
    namespace = "kube-system"
    chart = "sealed-secrets"
    version = "1.2.11"
    create_namespace = true
    values = [file("values/sealed-secrets.yaml")]
}
```

!!! tip "Reminder"
    You can use the helm show values command to see the values that you can edit in a helm chart. But first, you must add the repository to your helm repo list and update. For example:
    ```bash
    helm repo add argocd https://argoproj.github.io/argo-helm
    helm repo update
    helm show values argocd/argocd-image-updater --version 0.1.0 > show-argo-values.yaml
    ```


```bash
kubectl get pods -n kube-system | grep sealed-secrets # to verify that the sealed secrets controller is running and installled correctly
```

Kubeseal will use the following service to get a public key to encrypt our secrets:

```bash
kubectl get svc sealed-secrets -n kube-system
```

## New Workflow

Remmeber the repo secret 0-repo-secret.yaml? Well, in this new workflow, we will delete it from the cluster:

```bash
kubectl delete secret -n argocd -f 0-repo-secret.yaml
```

and use kubeseal to encrypt the file.

```bash
kubeseal --controller-name sealed-secrets -o yaml -n kube-system < path-to/0-repo-secret.yaml > path-to/1-sealed-repo-secret.yaml
```
`1-sealed-repo-secret.yaml` is the encrypted secret.

Then:

```bash
kubectl apply -f path-to/1-sealed-repo-secret.yaml -n argocd
```

The secret becomes safe to keep even in git. The secret can only be used with this cluster and no other because it is encrypted with the public key of this cluster. The secret can be used with the a private repo too.

---
