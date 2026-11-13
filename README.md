Sahab Tech – Azure Hub-and-Spoke Network Infrastructure

1. Project Overview

This project, named Sahab Tech, focuses on designing and deploying a cloud network infrastructure in Microsoft Azure using Terraform (Infrastructure as Code).

The architecture consists of three Virtual Networks (VNets) organized in a Hub-and-Spoke topology. All resources are deployed within the same Azure Resource Group, rglab1, unless otherwise specified.

The project aims to implement secure network connectivity, centralized traffic inspection, network segmentation, routing, and private DNS resolution.

2. Azure Resource Group

Resource Group: rglab1

Location: UAE North

3. Virtual Network Architecture

3.1 Vnet1 – Hub Network

Azure Name: Vnetlab1

Location: UAE North

Address Space: 10.20.0.0/21

Role: Central network (Hub)

The Hub VNet contains the following subnets:

Subnet

Address Prefix

Purpose

Development

10.20.0.0/24

Development workload network

Sales

10.20.1.0/25

Sales department network

Management

10.20.1.128/25

Management department network

GatewaySubnet

10.20.2.0/27

Reserved for Azure VPN Gateway or hybrid connectivity

AzureFirewallSubnet

10.20.3.0/24

Hosts Azure Firewall

The Development subnet is associated with a Network Security Group named nsg-dev-sub.

3.2 Vnet2 – Spoke 1

Azure Name: Vnetlab2

Location: UAE North

Address Space: 10.30.0.0/16

Role: Spoke network

Subnet configuration:

Subnet

Address Prefix

subnet21

10.30.0.0/24

Vnet2 is connected to the Hub through Virtual Network Peering.

3.3 Vnet3 – Spoke 2

Azure Name: Vnetlab3

Location: UAE North

Address Space: 10.40.0.0/16

Role: Spoke network

Subnet configuration:

Subnet

Address Prefix

sub-app

10.40.0.0/24

Vnet3 is connected to the Hub through Virtual Network Peering.

4. Network Connectivity and Security

4.1 Virtual Network Peering

Bidirectional VNet Peering is configured between:

Vnet1 (Hub) and Vnet2 (Spoke 1).

Vnet1 (Hub) and Vnet3 (Spoke 2).

The Hub-and-Spoke topology provides centralized network connectivity through the Hub.

4.2 Azure Firewall

An Azure Firewall named sahab_fw is deployed in the Hub network.

Firewall SKU: Standard

Firewall Tier: Standard

Subnet: AzureFirewallSubnet

Public IP: publicIP

The firewall provides centralized traffic filtering between the Spoke networks.

4.3 User Defined Routes (UDRs)

Two Route Tables are configured to direct traffic between the Spoke networks through Azure Firewall.

Route Table 1

Name: routtable1

Associated Subnet: subnet21 in Vnet2

Route: route1

Destination: 10.40.0.0/16

Next Hop Type: Virtual Appliance

Next Hop: Azure Firewall private IP address

Route Table 2

Name: routetable2

Associated Subnet: sub-app in Vnet3

Route: route11

Destination: 10.30.0.0/16

Next Hop Type: Virtual Appliance

Next Hop: Azure Firewall private IP address

These routes direct traffic between the two Spoke networks through the centralized firewall.

4.4 Network Security Group (NSG)

A Network Security Group named nsg-dev-sub is associated with the Development subnet in Vnet1.

An inbound security rule is configured to allow TCP traffic on destination port 80.

4.5 Azure Firewall Network Rules

Network Rule Collections are configured to allow HTTP traffic between Vnet2 and Vnet3:

Vnet2 to Vnet3: Allow TCP port 80.

Vnet3 to Vnet2: Allow TCP port 80.

5. Private DNS

An Azure Private DNS Zone named sahab.internal is configured to provide private DNS name resolution.

The DNS Zone is linked to all three Virtual Networks:

Vnet1

Vnet2

Vnet3

Auto-registration is disabled on all Virtual Network Links.

6. Infrastructure as Code

All Azure infrastructure resources are defined and managed using Terraform.

Terraform is used to provision and configure:

Resource Groups

Virtual Networks and Subnets

Network Security Groups

Virtual Network Peerings

Azure Firewall and Public IP

Route Tables and Route Associations

Firewall Network Rule Collections

Azure Private DNS Zone and Virtual Network Links

The project uses Terraform resource references to establish dependencies between related Azure resources.
