
resource "azurerm_resource_group" "rg" {
  location = "north europe"
  name = "AzureDBricks"
}

resource "azurerm_databricks_workspace" "workspace" {
  location = azurerm_resource_group.rg.location
  name = "workspaceDemo"
  resource_group_name = azurerm_resource_group.rg.name
  sku = "premium"
}

data "databricks_node_type" "smallest" {
  depends_on = [azurerm_databricks_workspace.workspace]
  local_disk= true

}

data "databricks_spark_version" "latest_lts" {
  depends_on = [azurerm_databricks_workspace.workspace]
  long_term_support = true
}

resource "databricks_instance_pool" "pool" {
  instance_pool_name = "Pool"
  min_idle_instances = 0
  max_capacity =  1
  node_type_id = data.databricks_node_type.smallest.id
  idle_instance_autotermination_minutes = 10
}

resource "databricks_cluster" "shared_autoscaller" {
  depends_on = [azurerm_databricks_workspace.workspace]
#  instance_pool_id = databricks_instance_pool.pool.id
  cluster_name = "Demo1"
 spark_version = "8.0.x-scala2.12"

  node_type_id = data.databricks_node_type.smallest.id
  autotermination_minutes = 20
  autoscale {
    min_workers = 0
    max_workers = 2
  }
  custom_tags = {
    "createdBy" = "shantanu"
  }

cluster_log_conf {
  dbfs {
    destination = "dbfs:/cluster-logs"
  }
}
  init_scripts {
    dbfs {
      destination = "dbfs:/databricks/spark-monitoring/spark-monitoring.sh"
    }
  }

}


resource "azurerm_storage_account" "storage" {
  account_replication_type = "LRS"
  account_tier = "Standard"
  location = azurerm_resource_group.rg.location
  name = "azuredbob1289"
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_storage_container" "container" {
  name = "azuredbcontainer"
  storage_account_name = azurerm_storage_account.storage.name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  location = azurerm_resource_group.rg.location
  name = "azuredbkv1297"
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"

}

resource "azurerm_key_vault_access_policy" "kv" {
  object_id = data.azurerm_client_config.current.object_id
  tenant_id = data.azurerm_client_config.current.tenant_id
  key_vault_id = azurerm_key_vault.keyvault.id
  secret_permissions = ["delete","get","list","set"]
}

//
resource "databricks_secret_scope" "kv" {
  name = "keyvault-viaTf"
  keyvault_metadata {
    resource_id = azurerm_key_vault.keyvault.id
    dns_name = azurerm_key_vault.keyvault.vault_uri
  }
}

resource "azurerm_key_vault_secret" "secret" {
  name = "azuredb-storage"
  value = azurerm_storage_account.storage.primary_access_key
  key_vault_id = azurerm_key_vault.keyvault.id
}

data "databricks_current_user" "me" {}

resource "databricks_notebook" "notebook" {
  content_base64 = base64encode(<<-EOT
   display("dbutils.fs.mounts()")
  EOT
)
  language = "PYTHON"
  path = "${data.databricks_current_user.me.home}/mountblob"
}


resource "databricks_secret_scope" "scope" {
  name  = "dbscope"
  initial_manage_principal = "users"
}
resource "databricks_secret" "dbsecret" {
  key =  "blob_primarykey"
  string_value = azurerm_storage_account.storage.primary_access_key
  scope = databricks_secret_scope.scope.name
}

resource "databricks_azure_blob_mount" "blob" {
  depends_on = [azurerm_databricks_workspace.workspace]
  container_name = azurerm_storage_container.container.name
  storage_account_name = azurerm_storage_account.storage.name
  mount_name = "custommount"
  auth_type = "ACCESS_KEY"
  token_secret_scope = databricks_secret_scope.scope.name
  token_secret_key = databricks_secret.dbsecret.key
}

resource "azurerm_log_analytics_workspace" "databrickslogs" {
  location = azurerm_resource_group.rg.location
  name = "databrickslogs4951"
  resource_group_name = azurerm_resource_group.rg.name
  sku = "PerGB2018"


}
