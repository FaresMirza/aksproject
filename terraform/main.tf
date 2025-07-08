provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "aks-rg"
  location = "UAE North"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  address_space       = ["10.100.0.0/16"]  # ✅ عنوان شبكة لا يتعارض مع AKS
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.100.1.0/24"]  # ✅ ضمن مدى الـ VNet
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myaks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "myaksdns"

  default_node_pool {
    name           = "default"
    node_count     = 2
    vm_size        = "Standard_B2s"  
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
    node_public_ip_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    network_policy     = "azure"
  }

  tags = {
    Environment = "Dev"
  }
}

resource "azurerm_role_assignment" "aks_subnet_permission" {
  scope                = azurerm_subnet.aks_subnet.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}

resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "nodeport_rule" {
  name                        = "Allow-NodePort"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["30000-32767"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "aks_nsg_association" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}