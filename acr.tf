resource "azurerm_resource_group" "acr_rg" {
  name     = var.acr_rg
  location = var.location
}

resource "random_string" "random" {
  length           = 5
  special          = false
  lower            = true
  upper            = "false"
  override_special = "!@#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_container_registry" "acr" {
  name                = "eliteconreg${random_string.random.result}"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = local.common_tags
}