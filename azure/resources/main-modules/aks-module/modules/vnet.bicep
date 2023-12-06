param location string = resourceGroup().location
param prefix string
param clusterName string
@description('The virtual network name')
param vnetName string = '${prefix}-vnet-${clusterName}-${location}'
@description('The name of the subnet')
param subnetName string = '${prefix}-snet-${clusterName}-${location}'
@description('The virtual network address prefixes')
param vnetAddressPrefixes array
@description('The subnet address prefix')
param subnetAddressPrefix string
@description('Tags for the resources')
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }      
    ]
  }
  tags: tags
}
 