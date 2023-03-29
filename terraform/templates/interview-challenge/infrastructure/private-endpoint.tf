resource "azurerm_private_dns_zone" "private_endpoint" {
    for_each = toset(var.private_dns_zone_names)
    name                = each.key
    resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_vnet" {
    for_each = { for dns_zone in azurerm_private_dns_zone.private_endpoint: dns_zone.name => dns_zone }
    name                  = azurerm_virtual_network.spoke_vnet.name
    resource_group_name   = azurerm_resource_group.rg.name
    private_dns_zone_name = each.value.name
    virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}
resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet" {
    for_each = { for dns_zone in azurerm_private_dns_zone.private_endpoint: dns_zone.name => dns_zone }
    name                  = azurerm_virtual_network.hub_vnet.name
    resource_group_name   = azurerm_resource_group.rg.name
    private_dns_zone_name = each.value.name
    virtual_network_id    = azurerm_virtual_network.hub_vnet.id
}