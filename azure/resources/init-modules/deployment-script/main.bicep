@description('Required. Config object that contains the resource definitions')
param config object
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing  = [for (account, index) in config.storageAccounts: if(contains(config.storageAccounts, 'storageAccounts')) {
  name: account.storageAccounts.name
}]


module deploymentScript 'modules/deployment-script.bicep' = [for ds in config.deploymentScripts: {
  name: ds.name
  params: {
    name: ds.name
    location: location
    storageName : ds.storageName
    filename: ds.filename
    containerName: ds.containerName
  }
  dependsOn:[
    storageAccount
  ]
}]
