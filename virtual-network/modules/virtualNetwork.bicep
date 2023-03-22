targetScope = 'resourceGroup'

@description('Name for the Virtual Network')
param virtualNetworkName string
@description('Location where the resource will be deployed') 
param location string = resourceGroup().location
@description('List of CIDR ranges that Virtual Network will use')
param virtualNetworkAddressPrefixes array
@description('List of subnet names, prefixes and security rules for NSG')
param subnets array

@description('Tags that will be applied to the resource')
param tags object = {}

resource natGateway 'Microsoft.Network/natGateways@2022-09-01' existing = [for (natGateway, i) in subnets: if(contains(natGateway, 'natGatewayName')) {
  name: natGateway.natGatewayName
  scope: resourceGroup(natGateway.natGatewayResourceGroup )
}]

// below block loops through the array 'subnets' with same name as subnet, but replaces 'snet' with 'nsg'
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-08-01' = [for (nsg, i) in subnets: if(nsg.name != 'GatewaySubnet' && nsg.name != 'AzureFirewallSubnet') {
  name: replace(nsg.name, 'snet', 'nsg')
  location: location
  properties: {
    securityRules: contains(nsg, 'securityRules') ? nsg.securityRules: []
  }
  tags: tags
}]

// below block loops through the array 'subnets' with same name as subnet, but replaces 'snet' with 'rt'
resource routeTable 'Microsoft.Network/routeTables@2022-09-01' = [for (rt, i) in subnets: if(rt.name != 'GatewaySubnet' && rt.name != 'AzureFirewallSubnet') {
  name: replace(rt.name, 'snet', 'rt')
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: contains(rt, 'routes') ? rt.routes : []
  }
  tags: tags
}]

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressPrefixes
    }
    // below block loops through the array 'subnets'
    // it's also using the loop in network security group, grabbing it's id
    subnets: [for (subnet, i) in subnets: {
      name: subnet.name 
      properties: {
        addressPrefix: subnet.subnetPrefix
        networkSecurityGroup: subnet.name != 'GatewaySubnet' && subnet.name != 'AzureFirewallSubnet' ? {
          id: networkSecurityGroup[i].id
        } : null
        routeTable: subnet.name != 'GatewaySubnet' && subnet.name != 'AzureFirewallSubnet' ? {
          id: routeTable[i].id
        } : null
        // below block is a conditional. if the subnet param does not have an entry named "delegations", no subnet delegation will happen 
        delegations: contains(subnet, 'delegations') ? subnet.delegations : null
        // below block is a conditional. if the subnet.natGatewayName parameter is is missing this step will be skipped.
        natGateway: contains(subnet, 'natGatewayName') ? { id: natGateway[i].id } : null
      }
    }]
  }
  tags: tags
}

output subnets array = [for (outputs, i) in subnets: outputs.name != 'GatewaySubnet' ? { 
  nsgName: networkSecurityGroup[i].name
  nsgId: networkSecurityGroup[i].id
  rtName: routeTable[i].name
  rtId: routeTable[i].id
} : {}]

output virtualNetwork object = {
  name: virtualNetwork.name
  id: virtualNetwork.id
}
