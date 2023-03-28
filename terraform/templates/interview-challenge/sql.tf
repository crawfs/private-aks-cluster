resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "_%@"
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}

resource "azurerm_sql_server" "sql" {
  name                         = "sql-${local.alphanumeric_name_suffix}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "jccadmin"
  administrator_login_password = random_password.password.result
}

resource "azurerm_private_endpoint" "postgresql_primary" {
  name                = "${azurerm_container_registry.acr.name}-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet[var.private_endpoint_subnet].spoke_vnet.id

  private_service_connection {
    name                           = "${azurerm_container_registry.acr.name}-private-endpoint"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = [
        "registry"
    ]
  }

  private_dns_zone_group {
    name = module.postgresql.postgresql_primary.name
    private_dns_zone_ids = [
        azurerm_private_dns_zone.private_endpoint["privatelink.azurecr.io"].id
    ]
  }
}