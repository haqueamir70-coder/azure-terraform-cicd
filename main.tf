terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.13"
    }
  }
}

provider "azurerm" {
  features {}
}

# The resource group is created and managed outside this Terraform state.
# Read it instead of attempting to create a duplicate.
data "azurerm_resource_group" "rg" {
  name = "rg-github-cicd-demo"
}

output "resource_group_id" {
  description = "ID of the pre-existing demo resource group."
  value       = data.azurerm_resource_group.rg.id
}

output "resource_group_location" {
  description = "Azure region of the pre-existing demo resource group."
  value       = data.azurerm_resource_group.rg.location
}
