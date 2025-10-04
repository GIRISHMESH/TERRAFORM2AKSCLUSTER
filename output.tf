output "aks_cluster_name" {
  description = "AKS Cluster Name"
  value       = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_cluster_id" {
  description = "AKS Cluster Resource ID"
  value       = azurerm_kubernetes_cluster.aks_cluster.id
}

output "aks_cluster_kubernetes_version" {
  description = "Kubernetes Version"
  value       = azurerm_kubernetes_cluster.aks_cluster.kubernetes_version
}

output "azure_ad_group_id" {
  description = "Azure AD Administrator Group ID"
  value       = azuread_group.aks_administrators.id
}

output "azure_ad_group_objectid" {
  description = "Azure AD Administrator Group Object ID"
  value       = azuread_group.aks_administrators.object_id
}

output "kube_admin_config_raw" {
  description = "Kubernetes admin kubeconfig (sensitive)"
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_admin_config_raw
  sensitive   = true
}

output "cluster_fqdn" {
  description = "AKS Cluster FQDN"
  value       = azurerm_kubernetes_cluster.aks_cluster.fqdn
}

output "node_resource_group" {
  description = "Node Resource Group Name"
  value       = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.insights.id
}
