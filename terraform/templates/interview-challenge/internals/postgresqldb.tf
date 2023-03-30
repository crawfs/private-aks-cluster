resource "azurerm_postgresql_database" "postgresql" {
  name                = "applogdb"
  resource_group_name = data.terraform_remote_state.azure.postgresql.resource_group_name
  server_name         = data.terraform_remote_state.azure.postgresql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}