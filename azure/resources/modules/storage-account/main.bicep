param name string
param kind string
param sku string
param containerName string
param location string = resourceGroup().location

module storageAccount 'modules/storage-account.bicep' = {
  name: name
  params: {
    name: name
    location: location
    containerName: containerName
    kind: kind
    sku: sku
  }
}
