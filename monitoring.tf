resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${var.environment}-${random_pet.aksrandom.id}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    Purpose     = "Container-Monitoring"
  }
}
