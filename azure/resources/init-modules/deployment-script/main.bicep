@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location


module deploymentScript 'modules/deployment-script.bicep' = [for script in config.deploymentScripts: {
  name: script.name
  params: {
    name: script.name
    location: location
    kind: script.kind
    properties: script.properties
    storage: script.storageAccount
  }
}]
