# We could have just added argocd using kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# Or we could have used direct helm install -> helm repo add argocd https://argoproj.github.io/argo-helm
# Then helm repo update
# Then helm install argocd -n argocd --create-namespace argocd/argo-cd --version 3.35.4
# But here we will install argocd using helm in tf 
# It makes it easier to manage the variables and dependencies
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.46.8"
  namespace        = "argocd"
  create_namespace = true
  timeout          = 600
  replace          = true
  values           = [file("values/argocd-values.yaml")]
}

### NOTES ###
# in values list we could have:
# "argocd-server.service.type=NodePort",
# "argocd-server.service.nodePort=8080",
# or specify the path to the values file (BEST PRACTICE)