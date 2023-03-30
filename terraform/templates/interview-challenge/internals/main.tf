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

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {
  }
}

provider "kubernetes" {
    host                   = data.terraform_remote_state.azure.kube_config_host
    client_certificate     = base64decode(data.terraform_remote_state.azure.kube_client_certificate)
    client_key             = base64decode(data.terraform_remote_state.azure.kube_client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.azure.kube_cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.azure.kube_config_host
    client_certificate     = base64decode(data.terraform_remote_state.azure.kube_client_certificate)
    client_key             = base64decode(data.terraform_remote_state.azure.kube_client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.azure.kube_cluster_ca_certificate)
  }
}

data "terraform_remote_state" "azure" {
  backend = "azure"

  config = {
        tenant_id            = "***"
        subscription_id      = "***"
        resource_group_name  = "tfstate-rg"
        storage_account_name = "immtfstate"
        container_name       = "terraform"
        key                  = "private-aks-infrastructure"
    }
  }
}
