terraform{
    required_providers {
      azurerm={
        source = "hashicorp/azurerm"
        version = "5.0.1"
      }
    }
}
provider "azurerm" {
    features {} 
  
}

resource "azurerm_resource_group" "rgtest" {
  name = "taaj"
  location = "eastus"
  
}
resource "azurerm_storage_account" "rgstor" {
  name = "stor4531"
  resource_group_name =azurerm_resource_group.rgtest.name
  location =azurerm_resource_group.rgtest.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}