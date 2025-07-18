provider "helm" {
  kubernetes = {
    # Path to the kubeconfig file because we are using kind
    config_path = "~/.kube/config"
  }
}

# If you were using a managed cluster e.g. AWS EKS
# You would dynamically obtain a token to authenticate with the cluster
# provider "helm" {
#     kubernetes {
#         host = aws_eks_cluster.example.endpoint
#         cluster_ca_certificate = base64decode(aws_eks_cluster.example.certificate_authority[0].data)
#         exec {
#             api_version = "client.authentication.k8s.io/v1alpha1"
#             args = ["eks", "get-token", "--cluster-name", "aws.eks_cluster.example.id"]
#             command = "aws"
#         }
#     }
# }
