terraform{
    required_providers{
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "~>3.0"

        }
    }
}

provider "azurerm" {
    features{}

}

resource "azurerm_resource_group" "rg"{
    name     = "rglab1"
    location = "UAE north"
}

resource "azurerm_virtual_network" "Vnet1"{
    name                = "Vnetlab1"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.20.0.0/21"]
}

resource "azurerm_subnet" "DEV" {
    name = "devsub"
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    resource_group_name  = azurerm_resource_group.rg.name
    address_prefixes     = ["10.20.0.0/24"]
}

resource "azurerm_subnet" "SAL" {
    name =   "sales"
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    resource_group_name = azurerm_resource_group.rg.name
    address_prefixes = [ "10.20.1.0/25" ]
}

resource "azurerm_subnet" "MAN" {
    name = "manag"
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    resource_group_name  = azurerm_resource_group.rg.name
    address_prefixes = ["10.20.1.128/25"]
  
}

resource "azurerm_subnet" "GATE" {
    name = "GatewaySubnet"
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    resource_group_name = azurerm_resource_group.rg.name
    address_prefixes = ["10.20.2.0/28"]
  
}
resource "azurerm_virtual_network" "Vnet2"{
    name = "Vnetlab2"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    address_space = ["10.30.0.0/16"]
}
resource "azurerm_subnet" "subnet21"{
    name = "subnet21"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.Vnet2.name
    address_prefixes = ["10.30.0.0/24"]
}
resource "azurerm_virtual_network_peering" "peer1to2"{
    name = "Vnet1ToVnet2"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    remote_virtual_network_id = azurerm_virtual_network.Vnet2.id
}
resource "azurerm_virtual_network_peering" "peer2to1"{
    name = "v2to1"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.Vnet2.name
    remote_virtual_network_id = azurerm_virtual_network.Vnet1.id

}