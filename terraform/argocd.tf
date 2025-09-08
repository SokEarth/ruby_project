# ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Install ArgoCD with Helm
resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "5.51.6"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]
}