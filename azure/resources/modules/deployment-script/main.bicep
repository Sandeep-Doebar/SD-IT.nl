param name string
param location string = resourceGroup().location
param kind string
param properties object
param storageAccount object

module deploymentScript 'modules/deployment-script.bicep' = {
  name: name
  params: {
    name: name
    location: location
    kind: kind
    properties: properties
    storage: storageAccount
  }
}
