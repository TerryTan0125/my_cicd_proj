output "service_node_port" {
  value = kubernetes_service.webapp.spec[0].port[0].node_port
}

output "service_name" {
  value = kubernetes_service.webapp.metadata[0].name
}

output "namespace" {
  value = kubernetes_namespace.app.metadata[0].name
}
