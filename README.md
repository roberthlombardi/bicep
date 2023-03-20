# bicep-vnet-module

This repository contains a virtual network module with support for looping subnets, network security groups, and route tables.



## What does the module support?

The following features are supported:

- Subnet loop: There is a built-in loop for subnets, network security groups, and route tables.
They all loop using the same list, and network security groups and route tables are not conditional at the moment.

- Subnet delegation: For each subnet in the loop, there is an option to delegate it to a specific Azure service
![delegations](./media/delegations.png)
    - To find the currently available delegations for your subnet:

  ```PowerShell
    az network vnet subnet list-available-delegations -l "location" -g "ResourceGroupExample" -o table
  ```

- NAT Gateway: For each subnet in the loop, there's an option to a attach a NAT gateway.
    - In order to attach a NAT gateway, the parameters "natGatewayName", and "natGatewayResourceGroup" must be filled in.

    - These values are conditionals, if they are left empty a NAT gateway will not be attached.
    Note that the NAT gateway currently must reside in the same subscription as the virtual network deployment.

    ![natGatewayParameters](./media/natGatewayParameters.png)



## Parameters

Parameter name | Required | Description
-------------- | -------- | -----------
virtualNetworkName | Yes      | Name for the Virtual Network
location       | No       | Location where the resource will be deployed
virtualNetworkAddressPrefixes | Yes      | List of CIDR ranges that Virtual Network will use
subnets        | Yes      | List of subnet names, prefixes and security rules for NSG
tags           | No       | Tags that will be applied to the resource

### virtualNetworkName

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

Name for the Virtual Network

### location

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Location where the resource will be deployed

- Default value: `[resourceGroup().location]`

### virtualNetworkAddressPrefixes

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

List of CIDR ranges that Virtual Network will use

### subnets

![Parameter Setting](https://img.shields.io/badge/parameter-required-orange?style=flat-square)

List of subnet names, prefixes and security rules for NSG

### tags

![Parameter Setting](https://img.shields.io/badge/parameter-optional-green?style=flat-square)

Tags that will be applied to the resource

## Outputs

Name | Type | Description
---- | ---- | -----------
subnets | array |
virtualNetwork | object |

## Snippets

### Parameter file

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "template": "C:\\Repository\\github-personal\\bicep-vnet-module\\virtual-network\\modules\\virtualNetwork.json"
    },
    "parameters": {
        "virtualNetworkName": {
            "value": ""
        },
        "location": {
            "value": "[resourceGroup().location]"
        },
        "virtualNetworkAddressPrefixes": {
            "value": []
        },
        "subnets": {
            "value": []
        },
        "tags": {
            "value": {}
        }
    }
}
```





## How to deploy

  ```PowerShell
az group create -n "ResourceGroupExample" -l "location"
  ```

  ```PowerShell
    az deployment group create -g "ResourceGroupExample" -f .\virtual-network\main.bicep -p .\virtual-network\vnetParameters.json
  ```