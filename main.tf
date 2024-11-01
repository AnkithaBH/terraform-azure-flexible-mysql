##----------------------------------------------------------------------------- 
## Vritual Network and Subnet Creation  
##-----------------------------------------------------------------------------
data "azurerm_client_config" "current" {}

##----------------------------------------------------------------------------- 
## Locals Declaration 
##-----------------------------------------------------------------------------
locals {
  resource_group_name = var.resource_group_name
  location            = var.location
}

##----------------------------------------------------------------------------- 
## Labels module callled that will be used for naming and tags.   
##-----------------------------------------------------------------------------
module "labels" {
  source      = "clouddrove/labels/azure"
  version     = "1.0.0"
  name        = var.name
  environment = var.environment
  managedby   = var.managedby
  label_order = var.label_order
  repository  = var.repository
}

##----------------------------------------------------------------------------- 
## Random Password Resource.
## Will be passed as admin password of mysql server when admin password is not passed manually as variable. 
##-----------------------------------------------------------------------------

resource "random_password" "main" {
  count       = var.admin_password == null ? 1 : 0
  length      = var.admin_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false
}

##----------------------------------------------------------------------------- 
## Below resource will create flexible mysql server in Azure environment.    
##-----------------------------------------------------------------------------

resource "azurerm_mysql_flexible_server" "main" {
  count                             = var.enabled ? 1 : 0
  name                              = var.mysql_server_name != null ? var.mysql_server_name : format("%s-mysql-flexible-server", module.labels.id)
  resource_group_name               = local.resource_group_name
  location                          = var.location
  administrator_login               = var.admin_username
  administrator_password            = var.admin_password == null ? random_password.main[0].result : var.admin_password
  backup_retention_days             = var.backup_retention_days
  delegated_subnet_id               = var.delegated_subnet_id
  private_dns_zone_id               = var.private_dns ? join("", azurerm_private_dns_zone.main.*.id) : var.existing_private_dns_zone_id
  sku_name                          = var.sku_name
  create_mode                       = var.create_mode
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  point_in_time_restore_time_in_utc = var.create_mode == "PointInTimeRestore" ? var.point_in_time_restore_time_in_utc : null
  replication_role                  = var.replication_role
  source_server_id                  = var.create_mode == "PointInTimeRestore" ? var.source_server_id : null
  storage {
    auto_grow_enabled = var.auto_grow_enabled
    iops              = var.iops
    size_gb           = var.size_gb
  }
  dynamic "high_availability" {
    for_each = toset(var.high_availability != null ? [var.high_availability] : [])

    content {
      mode                      = high_availability.value.mode
      standby_availability_zone = lookup(high_availability.value, "standby_availability_zone", 1)
    }
  }
  dynamic "identity" {
    for_each = toset(var.identity_type != null ? [var.identity_type] : [])
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" ? var.user_assigned_identity_ids : []
    }

  }

  version = var.mysql_version
  zone    = var.zone

  tags = var.custom_tags == null ? module.labels.tags : var.custom_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.main, azurerm_private_dns_zone_virtual_network_link.main2]
}

##----------------------------------------------------------------------------- 
## Below resource will create mysql server active directory administrator. 
##-----------------------------------------------------------------------------

resource "azurerm_mysql_flexible_server_active_directory_administrator" "main" {
  count = length(var.entra_authentication.object_id[*]) > 0 ? 1 : 0

  server_id   = join("", azurerm_mysql_flexible_server.main.*.id)
  identity_id = var.entra_authentication.user_assigned_identity_id
  login       = var.entra_authentication.login
  object_id   = var.entra_authentication.object_id
  tenant_id   = data.azurerm_client_config.current.tenant_id

  depends_on = [azurerm_mysql_flexible_server.main]
}

##----------------------------------------------------------------------------- 
## Below resource will create mysql flexible database. 
##-----------------------------------------------------------------------------

resource "azurerm_mysql_flexible_database" "main" {
  count               = var.enabled ? 1 : 0
  name                = var.db_name
  resource_group_name = local.resource_group_name
  server_name         = join("", azurerm_mysql_flexible_server.main.*.name)
  charset             = var.charset
  collation           = var.collation
  depends_on          = [azurerm_mysql_flexible_server_active_directory_administrator.main]
}

##----------------------------------------------------------------------------- 
## Below resource will create flexible mysql server configuration. 
##-----------------------------------------------------------------------------

resource "azurerm_mysql_flexible_server_configuration" "main" {
  count               = var.enabled ? length(var.server_configuration_names) : 0
  name                = element(var.server_configuration_names, count.index)
  resource_group_name = local.resource_group_name
  server_name         = join("", azurerm_mysql_flexible_server.main.*.name)
  value               = element(var.values, count.index)
}

##------------------------------------------------------------------------
## Manages a Customer Managed Key for a MySQL Server. - Default is "false"
##------------------------------------------------------------------------
resource "azurerm_mysql_server_key" "main" {
  count            = var.enabled && var.key_vault_key_id != null ? 1 : 0
  server_id        = join("", azurerm_mysql_flexible_server.main.*.id)
  key_vault_key_id = var.key_vault_key_id
}

##----------------------------------------------------------------------------- 
## Below resource will deploy private dns for flexible mysql server. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "main" {
  count               = var.enabled && var.private_dns ? 1 : 0
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = local.resource_group_name
  tags                = var.custom_tags == null ? module.labels.tags : var.custom_tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in above created mysql private dns resource. 
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  count                 = var.enabled && var.private_dns ? 1 : 0
  name                  = format("mysql-endpoint-link-%s", module.labels.id)
  private_dns_zone_name = join("", azurerm_private_dns_zone.main.*.name)
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = local.resource_group_name
  registration_enabled  = var.registration_enabled
  tags                  = var.custom_tags == null ? module.labels.tags : var.custom_tags
}

##----------------------------------------------------------------------------- 
## Below resource will create vnet link in previously existing mysql private dns zone.  
##-----------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "main2" {
  count                 = var.enabled && var.existing_private_dns_zone ? 1 : 0
  name                  = format("mysql-endpoint-link-%s", module.labels.id)
  private_dns_zone_name = var.existing_private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  resource_group_name   = var.main_rg_name
  registration_enabled  = var.registration_enabled
  tags                  = var.custom_tags == null ? module.labels.tags : var.custom_tags
}

resource "azurerm_monitor_diagnostic_setting" "mysql" {
  count                          = var.enabled && var.enable_diagnostic ? 1 : 0
  name                           = format("%s-mysql-diagnostic-log", module.labels.id)
  target_resource_id             = azurerm_mysql_flexible_server.main[0].id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.storage_account_id
  eventhub_name                  = var.eventhub_name
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  log_analytics_destination_type = var.log_analytics_destination_type
  dynamic "enabled_log" {
    for_each = var.log_category
    content {
      category = enabled_log.value
    }

  }

  dynamic "metric" {
    for_each = var.metric_enabled ? ["AllMetrics"] : []
    content {
      category = metric.value
      enabled  = true
    }
  }
}
