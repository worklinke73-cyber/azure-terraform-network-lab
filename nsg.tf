resource "azurerm_network_security_group" "nsg-dev" {

    name                = "nsg-dev-sub"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location

    security_rule {
    name = "sec-rule-1-nsg-dev"
    priority = 100
    access = "Allow"
    direction = "Inbound"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "80"
    source_address_prefix = "*"
    destination_address_prefix = "*"
 }
}

resource "azurerm_subnet_network_security_group_association" "nsg-ass-dev" {
    subnet_id = azurerm_subnet.DEV.id
    network_security_group_id = azurerm_network_security_group.nsg-dev.id
}
