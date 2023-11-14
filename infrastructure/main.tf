# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.73.0"
    }
  }
  backend "azurerm" {}
#  backend "azurerm" {
#    resource_group_name  = "quantyca-internal-giandomenico-avelluto"
#    storage_account_name = "quantycaodmterraform"
#    container_name       = "terraform-state"
#    key                  = "airline-demo/azuredevops.terraform.tfstate"
#    }
}

locals {
    # get json
    configurations = jsondecode(file("${path.module}/../config.json"))
}

provider "azurerm" {
  features {}
  subscription_id = local.configurations.azure.subscription_id
  tenant_id = local.configurations.azure.tenant_id
}

module "database" {
  source = "./modules/database"
  project_tags = var.PROJECT_TAGS
  region = local.configurations.azure.region
  resource_group_name = local.configurations.azure.resource_group_name
}

module "virtual_machines" {
  source = "./modules/virtual_machines"
  project_tags = var.PROJECT_TAGS
  region = local.configurations.azure.region
  resource_group_name = local.configurations.azure.resource_group_name
}
