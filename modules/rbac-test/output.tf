output "service_account_name" {
  value = kubernetes_service_account.rbac_test_sa.metadata[0].name
}
# output "app_name" {
#   value       = var.app_name
# }

# output "deployment_name" {
#   value       = kubernetes_deployment.app.metadata[0].name
# }

# output "service_name" {
#   value       = kubernetes_service.app.metadata[0].name
# }

# output "service_type" {
#   value       = kubernetes_service.app.spec[0].type
# }

# output "service_port" {
#   value       = kubernetes_service.app.spec[0].port[0].port
# }

# output "container_port" {
#   value       = kubernetes_deployment.app.spec[0].template[0].spec[0].container[0].port[0].container_port
# }
