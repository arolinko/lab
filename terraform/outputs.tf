output "nginx_ingress_ip" {
  description = "Public IP of the Nginx Ingress controller"
  value       = azurerm_public_ip.nginx_ingress_ip.ip_address
}

output "aks_cluster_name" {
  description = "AKS Cluster Name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}