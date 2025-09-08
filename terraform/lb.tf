# resource "kubernetes_manifest" "app_lb" {
#   manifest = {
#     apiVersion = "v1"
#     kind       = "Service"
#     metadata = {
#       name      = "gifmachine"
#       namespace = "default"
#     }
#     spec = {
#       type = "LoadBalancer"
#       selector = {
#         app = "gifmachine"
#       }
#       ports = [
#         {
#           port       = 80
#           targetPort = 4567
#         }
#       ]
#     }
#   }
# }
