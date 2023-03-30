resource "azurerm_virtual_network" "spoke_vnet" {
  name                = "spoke-vnet-${local.name_suffix}"
  address_space       = var.virtual_network_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = [
    "10.1.0.4"
  ]
  tags = var.tags
}

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub-vnet-${local.name_suffix}"
  address_space       = var.virtual_network_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = [
    "10.1.0.4"
  ]
  tags = var.tags
}

resource "azurerm_subnet" "spoke_vnet" {
  for_each = { for subnet in var.spoke_subnets: subnet.name => subnet }
  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_subnet" "hub_vnet" {
  for_each = { for subnet in var.spoke_subnets: subnet.name => subnet }
  name                 = each.value.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_subnet_network_security_group_association" "vnet" {
  for_each = local.valid_nsg_subnets
  subnet_id                 = azurerm_subnet.vnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_route_table" "rt" {
  name                = "rt-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  route {
    name                   = "kubenetfw_fw_r"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "subnet_association" {
  for_each = { for subnet in azurerm_subnet.spoke_vnet: subnet.name => subnet }

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.rt[0].id
}