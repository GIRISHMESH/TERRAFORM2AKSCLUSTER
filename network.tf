resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet-${var.environment}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name           = "aks-subnet"
    address_prefix = "10.0.1.0/24"
  }

  tags = {
    Environment = var.environment
    Type        = "AKS-Networking"
  }
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg-${var.environment}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTPS"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Optional: restrict Kubernetes API access to specified CIDR(s) if desired
  security_rule {
    name                       = "Allow_K8s_API"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"            # change to specific CIDR for stricter security
    destination_address_prefix = "VirtualNetwork"
  }

  tags = {
    Environment = var.environment
    Purpose     = "AKS-Security"
  }
}
# Example: associate NSG to the AKS subnet (recommended)
resource "azurerm_subnet_network_security_group_association" "aks_subnet_nsg" {
  subnet_id                 = azurerm_virtual_network.aks_vnet.subnet[0].id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}