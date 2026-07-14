output "namespace" {
  value = kubernetes_namespace.app_ns.metadata[0].name
}

output "deployment_name" {
  value = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.app_service.metadata[0].name
}

output "port_forward_command" {
  value = "kubectl port-forward -n ${kubernetes_namespace.app_ns.metadata[0].name} svc/${kubernetes_service.app_service.metadata[0].name} 8080:80"
}
