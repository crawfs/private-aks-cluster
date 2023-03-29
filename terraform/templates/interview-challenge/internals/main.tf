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

provider "helm" {
  kubernetes {
    host     = "https://cluster_endpoint:port"

    client_certificate     = file("~/.kube/client-cert.pem")
    client_key             = file("~/.kube/client-key.pem")
    cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
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
