resource "azurerm_public_ip" "gateway" {
    name                = "pip-vpn-${local.name_suffix}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    domain_name_label   = "pip-vpn-${local.name_suffix}"

    allocation_method   = "Static"
    sku                 = "Standard"
    zones               = [1,2,3]
}   

resource "azurerm_virtual_network_gateway" "gateway" {
    name                = "vpn-${local.name_suffix}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name

    type     = "Vpn"
    vpn_type = "RouteBased"

    active_active = false
    enable_bgp    = false
    sku           = "VpnGw1AZ"

    ip_configuration {
      name                          = "vnetGatewayConfig"
      public_ip_address_id          = azurerm_public_ip.gateway.id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = azurerm_subnet["GatewaySubnet"].id
    }
    vpn_client_configuration {
      vpn_client_protocols = [ "OpenVPN" ]
      address_space = ["172.21.0.0/24"]
      aad_tenant = "https://login.microsoftonline.com/${var.tenant_id}/"
      aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4"
      aad_issuer = "https://sts.windows.net/${var.tenant_id}/"
    }
}