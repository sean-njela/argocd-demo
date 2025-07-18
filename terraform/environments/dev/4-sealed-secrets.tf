resource "helm_release" "sealed_secrets" {
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  name             = "sealed-secrets"
  namespace        = "kube-system"
  chart            = "sealed-secrets"
  version          = "2.17.3"
  create_namespace = true
  timeout          = 600
  replace          = true
}
