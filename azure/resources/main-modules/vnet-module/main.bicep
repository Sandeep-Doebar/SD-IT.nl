@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module vnet 'modules/vnet.bicep' = [for vn in config.vnets: {
  name: vn.name
  params: {
    location: location
    prefix: vn.prefix
    clusterName: vn.clusterName
    vnetAddressPrefixes: vn.vnetAddressPrefixes
    subnetAddressPrefix: vn.subnetAddressPrefix
    tags: vn.tags
  }
}]
