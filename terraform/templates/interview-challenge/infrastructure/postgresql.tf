resource "random_password" "password" {
  length           = 24
  special          = true
  override_special = "_%@"
  min_lower = 1
  min_upper = 1
  min_numeric = 1
}

resource "azurerm_postgresql_server" "postgresql" {

  name                = "psql-${local.name_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "${local.alphanumeric_name_suffix}admin"
  administrator_login_password = random_password.password.result

  sku_name   = "GP_Gen5_4"
  version    = "11"
  storage_mb = 102400

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true
  infrastructure_encryption_enabled = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  threat_detection_policy {
    enabled = true
  }

  tags = merge(var.tags, {"deployment_region" = "primary_region"})
}

resource "azurerm_private_endpoint" "postgresql" {
  name                = "${azurerm_postgresql_server.psql.name}-private-endpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet[var.private_endpoint_subnet].spoke_vnet.id

  private_service_connection {
    name                           = "${azurerm_postgresql_server.psql.name}-private-endpoint"
    private_connection_resource_id = azurerm_postgresql_server.psql.id
    is_manual_connection           = false
    subresource_names              = [
        "postgresqlServer"
    ]
  }

  private_dns_zone_group {
    name = azurerm_postgresql_server.psql.name
    private_dns_zone_ids = [
        azurerm_private_dns_zone.private_endpoint["privatelink.postgres.database.azure.com"].id
    ]
  }
}