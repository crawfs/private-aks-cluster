terraform {
  required_version = "=1.1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.21.1"
    }
    tls = {
      source = "hashicorp/tls"
      version = "=3.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.4.3"
    }
  }
  backend "azurerm" {
    tenant_id            = "***"
    subscription_id      = "***"
    resource_group_name  = "tfstate-rg"
    storage_account_name = "immtfstate"
    container_name       = "terraform"
    key                  = "private-aks-infrastructure"
    snapshot             = true
  }
}

provider "tls" {
}

provider "random" {
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {
  }
}


provider "kubernetes" {
  alias = "primary"
  load_config_file       = false
  host                   = module.kubernetes["primary_location"].kube_config_host
  client_certificate     = base64decode(module.kubernetes["primary_location"].kube_client_certificate)
  client_key             = base64decode(module.kubernetes["primary_location"].kube_client_key)
  cluster_ca_certificate = base64decode(module.kubernetes["primary_location"].kube_cluster_ca_certificate)
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "=5.0.1"

  azure_region = var.location
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_suffix}"
  location = var.location
}