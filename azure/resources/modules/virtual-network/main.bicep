param name string
param addressPrefixes array
param subnets array
param location string = resourceGroup().location

module vnet 'modules/virtual-network.bicep' = {
  name: name
  params: {
    name: name
    addressPrefixes: addressPrefixes
    location: location
    subnets: subnets
  }
}
