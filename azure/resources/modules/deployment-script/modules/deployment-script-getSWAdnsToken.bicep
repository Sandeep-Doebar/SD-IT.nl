param name string
param location string = resourceGroup().location
param staticWebappName string
param customDomainName string
param managedIdentity object
param now string = utcNow('F')

resource managedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentity.name
  scope: resourceGroup(managedIdentity.resourceGroupName)
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: name
  kind: 'AzurePowerShell'
  location: location
  properties: {
    azPowerShellVersion: '3.0'
    scriptContent: loadTextContent('../../../scripts/getStaticWebAppDNStoken.ps1')
    arguments: '-subscriptionId ${subscription().subscriptionId} -resourceGroup ${resourceGroup().name} -staticSiteName ${staticWebappName} -customDomainName ${customDomainName}'
    retentionInterval: 'P1D'
    cleanupPreference: 'Always'
    forceUpdateTag: now
    timeout: 'PT5M'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResource.id}': {}
    }
  }
}

output validationToken string = deploymentScript.properties.outputs.validationToken
output isReady bool = deploymentScript.properties.outputs.isReady
