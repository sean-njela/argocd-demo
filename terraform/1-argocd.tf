# Here we will install argocd using helm
# It makes it easier to manage the variables and dependencies
resource "helm_release" "argocd" {
    name = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart = "argo-cd"
    version = "3.35.4"
    namespace = "argocd"
    create_namespace = true
    values = [file("values/argocd-values.yaml")]
}

### NOTES ###
# in values list we could have:
# "argocd-server.service.type=NodePort",
# "argocd-server.service.nodePort=8080",
# or specify the path to the values file (BEST PRACTICE)