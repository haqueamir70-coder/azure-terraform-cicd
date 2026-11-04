resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rgtest" {
  name     = "rg-terraform-cicd-lab"
  location = "eastus"
}

resource "azurerm_storage_account" "rgstor" {
  name                          = "sttf${random_string.suffix.result}"
  resource_group_name           = azurerm_resource_group.rgtest.name
  location                      = azurerm_resource_group.rgtest.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  min_tls_version               = "TLS1_2"
  https_traffic_only_enabled    = true
  shared_access_key_enabled     = false
  public_network_access_enabled = false
  allow_nested_items_to_be_public = false
}
