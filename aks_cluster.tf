### AKS Cluster (Public by default, unless private_cluster_enabled = true)
### Control plane is fully managed by Azure (in Microsoft’s subscription).
### Worker node pools, VNets, load balancers, and disks live in your subscription.
# The actual control plane (API server, etcd, scheduler) runs in Microsoft’s subscription.

data "azurerm_kubernetes_service_versions" "current" {
  location        = azurerm_resource_group.aks_rg.location
  include_preview = false
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name  #### main resource group--> holds for the AKS cluster object or  metadata — think of it as a pointer to your cluster
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  # Node resource group → worker nodes + infrastructure (VMSS, NICs, Disks, LB, etc.)
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"  

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

    # Worker node labels
    node_labels = {
      "nodepool-type" = "system"        # System pool runs k8s system components + workloads
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

  # Windows Profile → enables Windows worker node pools (if added later)
  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  # Linux Profile → provides SSH access for Linux worker nodes
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }

  # Identity for the cluster
  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    # Azure Policy → runs as admission controller on worker nodes
    azure_policy { enabled = true }

    # Monitoring agent (OMS/AMA) → runs as a DaemonSet on worker nodes
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
    }
  }

  # RBAC & AAD → integrated at API server level (control plane feature)
  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                = true
      admin_group_object_ids = [azuread_group.aks_administrators.id]
    }
  }

  # Networking → applied to worker nodes + services
  # API server communicates with this VNet but does not live inside it.
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

