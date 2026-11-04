# azure-terraform-network-lab
this terraform project is about creating Vnet in azure cloud using terraform,this project is called sahab tech has 3 Vnets 1- Vnet1 , 2 and 3 .

all of them are in the same resource group (rglab1) if there is any not in the same group i will mention it.

Vnet1 consists of 4 subnets development,sales,managment and GatewaySubnet for hybrid connectivity

Vnet1(uae north): starts from ["10.20.0.0/21"]
divided to :
1- development ["10.20.0.0/24"] associate it with NSG -->> nsg-dev-sub
2- sales ["10.20.1.0/25"]
3- managment ["10.20.1.128/25"]
4- GatewaySubnet ["10.20.2.0/28"]

Vnet2(uae north) starts from ["10.30.0.0/16"]
divided to:
1- subnet21 ["10.30.0.0/24"]
and there is a peering between these two Vnets 

Vnet3 : ["10.40.0.0/16"]
divided to: ["10.40.0.0/24"]
and there is a peering between these two Vnets
i created a route table routtable1 that has a route1 which makes the subnets of other Vents communicate with V3 and i added to it subnet21 which is in Vnet2
