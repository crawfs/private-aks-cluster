variable "location" {
    type = string
}
variable "tenant_id" {
    type = string
}
variable "subscription_id" {
    type = string
}
variable "shared_subscription_id" {
    type = string
}
variable "shared_tenant_id" {
    type = string
}
variable "environment" {
    type = string
}
variable "spoke_virtual_network_address_space" {
    description = "The address space for the virtual network"
    type = list(string)
}
variable "hub_virtual_network_address_space" {
    description = "The address space for the virtual network"
    type = list(string)
}
variable "spoke_subnets" {
    description = "The object for creation of the virtual network subnets"
    type = list(object({
        name = string
        address_prefixes = list(string)
    }))
}
variable "hub_subnets" {
    description = "The object for creation of the virtual network subnets"
    type = list(object({
        name = string
        address_prefixes = list(string)
    }))
}
variable "dns_zone_name" {
    type = string
}
variable "dns_zone_rg" {
    type = string
}
variable "aks_subnet_name" {
    description = "The name of the subnet that the aks cluster will be provisioned in"
    type = string
}
variable "aks_default_node_pool" {
    description = "The definition for the aks default node pool"
    type = object({
        name = string
        min_count = number
        max_count = number
        vm_size = string
        availability_zones = list(number)
    })
}
variable "tags" {
  description = "A map of tags for all resources to have assigned"
  type = map
}
variable "private_endpoint_subnet" {
  description = "The name of the subnet that contains the private endpoint resources"
}
variable "private_dns_zone_names" {
  description = "The name of the subnet that contains the private endpoint resources"
  type = list(string)
}