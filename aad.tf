resource "azuread_group" "aks_administrators" {
  name             = "${azurerm_resource_group.aks_rg.name}-cluster-administrators"
  description      = "AKS administrators for ${azurerm_resource_group.aks_rg.name}-cluster"
  security_enabled = true
}
