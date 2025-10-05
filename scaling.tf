# Linux user pool for app workloads
resource "azurerm_kubernetes_cluster_node_pool" "linux_user_pool" {
  name                  = "linuxpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_DS2_v2"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  mode                  = "User"
  os_type               = "Linux"


vnet_subnet_id        = azurerm_subnet.aks_linux.id   # <--- added


  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 5
  node_count            = 2
  os_disk_size_gb       = 64
  availability_zones    = [1, 2, 3]

  node_labels = {
    nodepool-type = "linux"
    environment   = var.environment
    scaling       = "enabled"
    workload      = "applications"
  }

  node_taints = [
    "workload=applications:NoSchedule"
  ]

  tags = {
    CostCenter   = "IT"
    Environment  = var.environment
    Scaling      = "Auto"
    Workload     = "Applications"
  }
}

# Windows node pool
resource "azurerm_kubernetes_cluster_node_pool" "windows_pool" {
  name                  = "windowspool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
  vm_size               = "Standard_D2s_v3"
  orchestrator_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  mode                  = "User"
  os_type               = "Windows"


vnet_subnet_id        = azurerm_subnet.aks_windows.id   # <--- added

  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 3
  node_count            = 1
  os_disk_size_gb       = 128
  availability_zones    = [1, 2, 3]

  node_labels = {
    nodepool-type = "windows"
    environment   = var.environment
    scaling       = "enabled"
    workload      = "windows-apps"
  }

  node_taints = [
    "os=windows:NoSchedule"
  ]

  tags = {
    CostCenter   = "IT"
    Environment  = var.environment
    Scaling      = "Auto"
    Workload     = "Windows-Apps"
    Compliance   = "ISO27001"
  }
}


