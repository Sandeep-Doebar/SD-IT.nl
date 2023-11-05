param config object
param location string = resourceGroup().location

module storageAccount 'modules/storage-account.bicep' = [for storageAccount in config.storageAccounts: {
  name: storageAccount.name
  params: {
    name: storageAccount.name
    location: location
    containerName: storageAccount.containerName
    kind: storageAccount.kind
    sku: storageAccount.sku
  }
}]
