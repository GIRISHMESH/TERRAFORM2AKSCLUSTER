resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet-${var.environment}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.0.0.0/16"]

#Instead of a single subnet block inside the azurerm_virtual_network, split them into dedicated azurerm_subnet resources.
 # subnet {
 #   name           = "aks-subnet"
#    address_prefix = "10.0.1.0/24"
#  }

tags = {
    Environment = var.environment
    Type        = "AKS-Networking"
  }
}


# --- Subnets ---
resource "azurerm_subnet" "aks_system" {
  name                 = "aks-system-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_linux" {
  name                 = "aks-linux-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "aks_windows" {
  name                 = "aks-windows-subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}





resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg-${var.environment}"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

resource "azurerm_subnet_network_security_group_association" "aks_linux_nsg" {
  subnet_id                 = azurerm_subnet.aks_linux.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "aks_windows_nsg" {
  subnet_id                 = azurerm_subnet.aks_windows.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}


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
# --- NSG Associations ---
resource "azurerm_subnet_network_security_group_association" "aks_system_nsg" {
  subnet_id                 = azurerm_subnet.aks_system.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "aks_linux_nsg" {
  subnet_id                 = azurerm_subnet.aks_linux.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "aks_windows_nsg" {
  subnet_id                 = azurerm_subnet.aks_windows.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}
