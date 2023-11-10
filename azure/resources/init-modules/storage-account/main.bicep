@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module storageAccountt 'modules/storage-account.bicep' = [for storageAccount in config.storageAccounts: {
  name: storageAccount.name
  params: {
    name: storageAccount.name
    location: location
    containerName: storageAccount.containerName
    kind: storageAccount.kind
    sku: storageAccount.sku
  }
}]
module deploymentScript 'modules/deployment-script.bicep' = [for storageAccount in config.storageAccounts: {
  name: storageAccount.deploymentScripts.name
  params: {
    name: storageAccount.deploymentScripts.name
    location: location
    storageName : storageAccount.name
    filename: storageAccount.deploymentScripts.filename
    containerName: storageAccount.containerName
  }
  dependsOn:[
    storageAccountt
  ]
}]
