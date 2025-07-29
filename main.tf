
provider "azurerm" {
  features {}

  subscription_id = "cd70a161-3537-4b00-bb7b-13e422cbcc98"
  tenant_id       = "f28f3563-ef6b-4fb2-aac1-327c53835bba"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "tfstorage937462" # ✅ Unique globally (letters + numbers, lowercase, 3–24>
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "tfcontainer"
  storage_account_id    = azurerm_storage_account.sa.id # ✅ No more deprecation warning
  container_access_type = "private"
}

