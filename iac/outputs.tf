output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config
  sensitive = true
}

output "host" {
  description = "Adresse du cluster AKS"
  value       = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive   = true
}
