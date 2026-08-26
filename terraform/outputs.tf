output "aks_name" {
  description = "Name of the AKS cluster created by this project."
  value       = azurerm_kubernetes_cluster.this.name
}

output "location" {
  description = "Azure region used by the project."
  value       = var.location
}

output "storage_account_name" {
  description = "Storage account containing the Velero backup container."
  value       = azurerm_storage_account.velero.name
}

output "velero_container_name" {
  description = "Name of the private Blob container used by Velero."
  value       = azurerm_storage_container.velero.name
}

output "velero_identity_client_id" {
  description = "Client ID placed on the Velero Kubernetes ServiceAccount."
  value       = azurerm_user_assigned_identity.velero.client_id
}

output "velero_identity_name" {
  description = "Name of the user-assigned identity used by Velero."
  value       = azurerm_user_assigned_identity.velero.name
}
