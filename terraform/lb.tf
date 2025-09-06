resource "kubernetes_manifest" "app_lb" {
  manifest = {
    apiVersion = "v1"
    kind       = "Service"
    metadata = {
      name      = "demo-app"
      namespace = "default"
    }
    spec = {
      type = "LoadBalancer"
      selector = {
        app = "demo-app"
      }
      ports = [
        {
          port       = 80
          targetPort = 4567
        }
      ]
    }
  }
}
