provider "azurerm" {
  version = "=2.26.0"
  features {}
}

resource "azurerm_resource_group" "mcp-rg" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
}

resource "azurerm_network_ddos_protection_plan" "mcp-ddos" {
  name                = "ddospplan1"
  location            = azurerm_resource_group.mcp-rg.location
  resource_group_name = azurerm_resource_group.mcp-rg.name
}

resource "azurerm_virtual_network" "mcp-vnet" {
  name                = var.virtual_network_name
  location            = azurerm_resource_group.mcp-rg.location
  address_space       = ["192.168.0.0/24"]
  resource_group_name = azurerm_resource_group.mcp-rg.name

ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.mcp-ddos.id
    enable = true
  }
}

resource "azurerm_subnet" "web-subnet" {
  name                 = "{var.prefix}webtier-sn01"
  virtual_network_name = azurerm_virtual_network.mcp-vnet.name
  resource_group_name  = azurerm_resource_group.mcp-rg.name
  address_prefixes       = ["192.168.0.0/26"]
}

resource "azurerm_subnet" "app-subnet" {
  name                 = "{var.prefix}apptier-sn01"
  virtual_network_name = azurerm_virtual_network.mcp-vnet.name
  resource_group_name  = azurerm_resource_group.mcp-rg.name
  address_prefixes       = ["192.168.0.64/26"]
}

resource "azurerm_subnet" "data-subnet" {
  name                 = "{var.prefix}datatier-sn01"
  virtual_network_name = azurerm_virtual_network.mcp-vnet.name
  resource_group_name  = azurerm_resource_group.mcp-rg.name
  address_prefixes       = ["192.168.0.128/26"]
}

resource "azurerm_subnet" "dmz-subnet" {
  name                 = "{var.prefix}dmztier-sn01"
  virtual_network_name = azurerm_virtual_network.mcp-vnet.name
  resource_group_name  = azurerm_resource_group.mcp-rg.name
  address_prefixes       = ["192.168.0.192/27"]
}

resource "azurerm_subnet" "gw-subnet" {
  name                 = "{var.prefix}gwtier-sn01"
  virtual_network_name = azurerm_virtual_network.mcp-vnet.name
  resource_group_name  = azurerm_resource_group.mcp-rg.name
  address_prefixes       = ["192.168.0.224/27"]
}

resource "azurerm_network_security_group" "mcp-websg" {
  name                = "{var.prefix}webtier-nsg01"
  resource_group_name = azurerm_resource_group.mcp-rg.name
  location            = azurerm_resource_group.mcp-rg.location
security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_network_security_group" "mcp-appsg" {
  name                = "{var.prefix}apptier-nsg01"
  resource_group_name = azurerm_resource_group.mcp-rg.name
  location            = azurerm_resource_group.mcp-rg.location
security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_network_security_group" "mcp-datasg" {
  name                = "{var.prefix}datatier-nsg01"
  resource_group_name = azurerm_resource_group.mcp-rg.name
  location            = azurerm_resource_group.mcp-rg.location
security_rule {
    name                       = "RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name                       = "SSH"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_network_security_group" "mcp-dmzsg" {
  name                = "{var.prefix}dmztier-nsg01"
  resource_group_name = azurerm_resource_group.mcp-rg.name
  location            = azurerm_resource_group.mcp-rg.location
}

resource "azurerm_subnet_network_security_group_association" "webnsg-associate" {
  subnet_id                 = azurerm_subnet.web-subnet.id
  network_security_group_id = azurerm_network_security_group.mcp-websg.id
}

resource "azurerm_subnet_network_security_group_association" "appnsg-associate" {
  subnet_id                 = azurerm_subnet.app-subnet.id
  network_security_group_id = azurerm_network_security_group.mcp-appsg.id
}

resource "azurerm_subnet_network_security_group_association" "datansg-associate" {
  subnet_id                 = azurerm_subnet.data-subnet.id
  network_security_group_id = azurerm_network_security_group.mcp-datasg.id
}

resource "azurerm_subnet_network_security_group_association" "dmznsg-associate" {
  subnet_id                 = azurerm_subnet.dmz-subnet.id
  network_security_group_id = azurerm_network_security_group.mcp-dmzsg.id
}