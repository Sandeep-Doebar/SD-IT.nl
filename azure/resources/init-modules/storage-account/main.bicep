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
 // module functionApp 'modules/function-app.bicep' = [for storageAccount in config.storageAccounts: {
 //   name: storageAccount.functionApp.name
 //   params: {
 //     name: storageAccount.deploymentScript.name
 //     location: location
 //     storageName : storageAccount.name
 //   }
 // }]


module deploymentScript 'modules/deployment-script.bicep' = [for storageAccount in config.storageAccounts: {
  name: storageAccount.deploymentScripts.name
  params: {
    name: storageAccount.deploymentScripts.name
    location: location
    storageName : storageAccount.name
    filename: storageAccount.deploymentScripts.filename
    containerName: storageAccount.containerName
  }
}]
