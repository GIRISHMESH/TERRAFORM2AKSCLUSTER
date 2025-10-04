data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.aks_rg.location
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name  ###main RG = managed control plane (master)
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  # Separate resource group for node resources
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg" ##node RG = worker nodes.

  default_node_pool {
    name                 = "systempool"
    vm_size              = "Standard_DS2_v2"
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    availability_zones   = [1, 2, 3]
    enable_auto_scaling  = true
    min_count            = 1
    max_count            = 3
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }

    tags = {
      CostCenter   = "IT"
      Environment  = var.environment
      Compliance   = "PCI-DSS"
      ManagedBy    = "Terraform"
    }
  }

  # Windows Profile (retain but consider using Key Vault in production)
  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  # Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  identity {
    type = "SystemAssigned"
  }



  addon_profile {
    azure_policy { enabled = true }


    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
    }
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [azuread_group.aks_administrators.id]
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "Standard"
    network_policy    = "calico"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
  }

  tags = {
    Environment  = var.environment
    Project      = "AKS-Platform"
    BusinessUnit = "PlatformEngineering"
    ManagedBy    = "Terraform"
    CostCenter   = "IT-Platform"
  }
}

