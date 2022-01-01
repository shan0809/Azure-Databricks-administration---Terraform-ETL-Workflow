

terraform {
  required_providers {
    databricks = {
      source = "databrickslabs/databricks"
      version =  "0.3.1"
    }
  }
}

provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.workspace.id
}
provider "azurerm" {
  features {}
  client_id = ""
  client_secret = ""
  tenant_id = ""
  subscription_id = ""
}
