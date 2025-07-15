# We could have run:
# helm repo add argocd https://argoproj.github.io/argo-helm
# helm repo update
# helm install -n argocd argocd/argocd-image-updater --version 0.8.0 -f terraform/values/image-updater-values.yaml

resource "helm_release" "argocd_image_updater" {
  name             = "argocd-image-updater"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  version          = "0.8.4"
  namespace        = "argocd"
  create_namespace = true
  values           = [file("values/image-updater-values.yaml")]
}