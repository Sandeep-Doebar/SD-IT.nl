@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module storageAccount 'modules/storage-account.bicep' = [for sa in config.storageAccounts: {
  name: sa.name
  params: {
    name: sa.name
    location: location
    containerName: sa.containerName
    kind: sa.kind
    sku: sa.sku
  }
}]
module deploymentScript 'modules/deployment-script.bicep' = [for sa in config.storageAccounts: {
  name: sa.deploymentScripts.name
  params: {
    name: sa.deploymentScripts.name
    location: location
    storageName : sa.name
    filename: sa.deploymentScripts.filename
    containerName: sa.containerName
  }
  dependsOn:[
    storageAccount
  ]
}]
