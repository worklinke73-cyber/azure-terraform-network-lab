terraform{
    required_providers{
        azurerm = {
        source  ="hashicorp/azurerm"
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
#Vnet1
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
    address_prefixes = ["10.20.2.0/27"]
  
}
resource "azurerm_subnet" "firewall"{
    name = "AzureFirewallSubnet"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.Vnet1.name
    address_prefixes = ["10.20.3.0/24"]

}
#Vnet2
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
    allow_forwarded_traffic = true
}
resource "azurerm_virtual_network_peering" "peer2to1"{
    name = "v2to1"
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.Vnet2.name
    remote_virtual_network_id = azurerm_virtual_network.Vnet1.id
    allow_forwarded_traffic = true

}

# 1. إنشاء الشبكة الثالثة Vnetlab3 (Spoke 2)
resource "azurerm_virtual_network" "Vnet3" {
  name                  = "Vnetlab3"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  address_space         = ["10.40.0.0/16"]
}

# 2. إنشاء السبنت داخل Vnetlab3
resource "azurerm_subnet" "subnet31" {
  name                   = "sub-app"
  resource_group_name    = azurerm_resource_group.rg.name
  virtual_network_name   = azurerm_virtual_network.Vnet3.name
  address_prefixes       = ["10.40.0.0/24"]
}

# 3. ربط Hub (Vnet1) بـ Spoke 2 (Vnet3) - الاتجاه الأول
resource "azurerm_virtual_network_peering" "peer1to3" {
  name                       = "Vnet1ToVnet3"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.Vnet1.name
  remote_virtual_network_id  = azurerm_virtual_network.Vnet3.id
  allow_forwarded_traffic = true
}

# 4. ربط Spoke 2 (Vnet3) بـ Hub (Vnet1) - الاتجاه العكسي
resource "azurerm_virtual_network_peering" "peer3to1" {
  name                       = "Vnet3ToVnet1"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_name       = azurerm_virtual_network.Vnet3.name
  remote_virtual_network_id  = azurerm_virtual_network.Vnet1.id
  allow_forwarded_traffic = true
}

resource "azurerm_route_table" "RT-1" {
    name = "routtable1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    bgp_route_propagation_enabled = false
}
#route to Vnet3
resource "azurerm_route" "ruleroute1"{
    name                   = "route1"
    resource_group_name    = azurerm_resource_group.rg.name
    route_table_name       = azurerm_route_table.RT-1.name
    address_prefix         = azurerm_virtual_network.Vnet3.address_space[0]
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.sahab_fw.ip_configuration[0].private_ip_address
}
resource "azurerm_subnet_route_table_association" "subnet21RT1"{
    subnet_id = azurerm_subnet.subnet21.id
    route_table_id = azurerm_route_table.RT-1.id
}
resource "azurerm_public_ip" "pub_ip"{
    name                = "publicIP"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"

}
resource "azurerm_firewall" "sahab_fw"{
    name = "sahab_fw"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku_name            = "AZFW_VNet"
    sku_tier            = "Standard"
    ip_configuration{
        name                 = "ip_con"
        subnet_id            = azurerm_subnet.firewall.id
        public_ip_address_id = azurerm_public_ip.pub_ip.id
           }
}
resource "azurerm_route_table" "RT_2"{
    name = "routetable2"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    bgp_route_propagation_enabled = false
}

resource "azurerm_route" "route11" {
  name = "route11"
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name = azurerm_route_table.RT_2.name

  address_prefix = azurerm_virtual_network.Vnet2.address_space[0]
  next_hop_type = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.sahab_fw.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "subnet31RT2" {
    subnet_id = azurerm_subnet.subnet31.id
    route_table_id = azurerm_route_table.RT_2.id
}

resource "azurerm_firewall_network_rule_collection" "fnrc1" {
    name = "allow-vnet2-to-vnet3"
    resource_group_name = azurerm_resource_group.rg.name
    azure_firewall_name = azurerm_firewall.sahab_fw.name

    priority = 100
    action = "Allow"

    rule {
      name = "allow-http"
      protocols = ["TCP"]

      source_addresses = [ "10.30.0.0/16" ]

      destination_addresses = [ "10.40.0.0/16" ]

      destination_ports = ["80"]
    }
}

resource "azurerm_firewall_network_rule_collection" "fnrc2" {
    name = "allow-vnet3-to-vnet2"
    resource_group_name = azurerm_resource_group.rg.name
    azure_firewall_name = azurerm_firewall.sahab_fw.name

    priority = 110
    action = "Allow"

    rule {
      name = "allow-http"
      protocols = ["TCP"]

      source_addresses = [ "10.40.0.0/16" ]

      destination_addresses = [ "10.30.0.0/16" ]

      destination_ports = ["80"]
    }
}
resource "azurerm_private_dns_zone" "sahab_dns" {
  name                = "sahab.internal"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_hub" {
  name                  = "link-hub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sahab_dns.name
  virtual_network_id    = azurerm_virtual_network.Vnet1.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_spoke1" {
  name                  = "link-spoke1"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sahab_dns.name
  virtual_network_id    = azurerm_virtual_network.Vnet2.id
  registration_enabled = false
}
resource "azurerm_private_dns_zone_virtual_network_link" "link_spoke2" {
  name                  = "link-spoke2"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sahab_dns.name
  virtual_network_id    = azurerm_virtual_network.Vnet3.id
  registration_enabled = false
}