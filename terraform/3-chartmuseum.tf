# This will be instead of using:
# helm add chartmuseum https://chartmuseum.github.io/charts
# helm repo update
# helm install -n chartmuseum chartmuseum/chartmuseum --version 3.9.3 -f terraform/values/chartmuseum.yaml

resource "helm_release" "chartmuseum" {
  name             = "chartmuseum"
  repository       = "https://chartmuseum.github.io/charts"
  chart            = "chartmuseum"
  version          = "3.9.3"
  namespace        = "chartmuseum"
  create_namespace = true
  values           = [file("values/chartmuseum.yaml")]
}