provider "azurerm" {
  features {}

  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Subnet for AKS cluster
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_role_assignment" "aks_app_vnet_role_assignment" {
  scope                = azurerm_virtual_network.aks_vnet.id
  role_definition_name = "Network Contributor"
  principal_id         = var.principal_id    

  depends_on = [azurerm_virtual_network.aks_vnet]

  timeouts {}
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "pool1"
    node_count = var.node_count
    vm_size    = var.vm_size
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }


 role_based_access_control_enabled = true  # Updated RBAC configuration

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
  }

  depends_on = [azurerm_subnet.aks_subnet]
}


# Public IP for Nginx Ingress
resource "azurerm_public_ip" "nginx_ingress_ip" {
  name                = var.nginx_ingress_ip_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Role assignment for Service Principal on Public IP (Contributor role)
resource "azurerm_role_assignment" "spn_contributor_public_ip" {
  principal_id   = var.principal_id
  role_definition_name = "Network Contributor"
  scope          = azurerm_public_ip.nginx_ingress_ip.id

  depends_on = [ azurerm_public_ip.nginx_ingress_ip ]
}

