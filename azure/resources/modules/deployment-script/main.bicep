param name string
param type string
param location string = resourceGroup().location
param kind string = ''
param identity object = {}
param properties object = {}
param storageAccount object = {}
param staticWebappName string = ''
param customDomainName string = ''

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

module deploymentScriptgetDNSTokenSWA 'modules/deployment-script-getSWAdnsToken.bicep' = if(type == 'getDNSTokenSWA') {
  name: name
  params: {
    name: name
    location: location
    staticWebappName: staticWebappName
    customDomainName: customDomainName
    managedIdentity: identity
  }
}

output validationToken string = (type == 'getDNSTokenSWA') ? deploymentScriptgetDNSTokenSWA.outputs.validationToken : ''
output isReady bool = (type == 'getDNSTokenSWA') ? deploymentScriptgetDNSTokenSWA.outputs.isReady : false
