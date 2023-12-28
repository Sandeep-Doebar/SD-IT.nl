param name string
param type string
param location string = resourceGroup().location
param kind string
param identity object
param properties object
param storageAccount object
param servicePrincipal object

module deploymentScriptUploadBlob 'modules/deployment-script-uploadBlob.bicep' = if(type == 'uploadBlob') {
  name: name
  params: {
    name: name
    location: location
    kind: kind
    properties: properties
    storage: storageAccount
  }
}
