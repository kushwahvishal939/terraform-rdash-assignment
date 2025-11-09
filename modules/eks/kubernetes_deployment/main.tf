# resource "kubernetes_deployment" "app" {
#   metadata {
#     name = var.app_name
#     labels = { app = var.app_name }
#   }

#   spec {
#     replicas = var.replicas
#     selector { match_labels = { app = var.app_name } }

#     template {
#       metadata { labels = { app = var.app_name } }

#       spec {
#         container {
#           name  = var.app_name
#           image = var.image
#           port { container_port = var.container_port }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "app" {
#   metadata { name = "${var.app_name}-svc" }

#   spec {
#     selector = { app = var.app_name }
#     port {
#       port        = var.service_port
#       target_port = var.container_port
#     }
#     type = "ClusterIP"
#   }
# }
