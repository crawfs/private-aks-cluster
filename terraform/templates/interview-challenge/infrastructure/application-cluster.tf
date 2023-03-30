resource "tls_private_key" "aks" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

resource "azurerm_private_dns_zone" "aks" {
    name                = "privatelink.${var.location}.azmk8s.io"
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  name = "aks-${local.name_suffix}Identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acr_pull" {
  role_definition_name = "AcrPull"
  scope                = module.container_registry.id
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}

resource "azurerm_public_ip" "aks" {
  name                = "aks-${local.name_suffix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
  zones               = [1,2,3]
  sku                 = "Standard"
  tags = var.tags
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${local.name_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-${local.name_suffix}"
  role_based_access_control_enabled = true
  kubernetes_version = "1.25.5"
  private_cluster_enabled = true
  private_dns_zone_id     = azurerm_private_dns_zone.aks.id

  default_node_pool {
    name       = var.aks_default_node_pool.name
    min_count  = var.aks_default_node_pool.min_count
    max_count  = var.aks_default_node_pool.max_count
    vm_size    = var.aks_default_node_pool.vm_size
    zones      = var.aks_default_node_pool.availability_zones
    enable_auto_scaling = true
    max_pods = 110
    vnet_subnet_id = var.aks_subnet_id
  }

  identity {
    type = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
  }

  role_based_access_control {
    enabled = var.role_based_access_control_enabled

    azure_active_directory {
      managed                = true
      tenant_id              = var.tenant_id
      admin_group_object_ids = var.admin_group_object_ids
      azure_rbac_enabled     = var.azure_rbac_enabled
    }
  }

  linux_profile {
      admin_username = "jccadmin"
      ssh_key {
        key_data = tls_private_key.aks.public_key_openssh
      }
  }
  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.aks.id]
    }
  }
}