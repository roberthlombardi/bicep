targetScope = 'resourceGroup'

@description('Name for the Virtual Network')
param virtualNetworkName string 
@description('Location where the resource will be deployed')
param location string = resourceGroup().location
@description('List of CIDR ranges that Virtual Network will use')
param virtualNetworkAddressPrefixes array = []
@description('List of subnet names, prefixes and security rules for NSG')
param subnets array = []

@description('Tags that will be applied to the resource')
param tags object = {}

module virtualNetwork 'modules/virtualNetwork.bicep' = {
  name: virtualNetworkName
  params: {
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    subnets: subnets
    location: location
    tags: tags
  }
}
