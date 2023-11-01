
param keyvaultName string
param location string
param resourceGroupName string = resourceGroup().name
param subscription string
param secretsArray array = []
param managedIdentityName string
param managedIdentityResourceGroupName string

resource managedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
  scope: resourceGroup(managedIdentityResourceGroupName)
}

var arguments = '"${keyvaultName}" "${resourceGroupName}" "${subscription}" "${secretsArray}"'

module deploymentScripts 'br:iodigital.azurecr.io/bicep/modules/deployment-scripts:v0.1' = {
  name: '${uniqueString(deployment().name, location)}-test-rdsps'
  params: {
    // Required parameters
    name: '${keyvaultName}-rdsps001'
    // Non-required parameters
    azCliVersion: '2.50.0'
    kind: 'AzureCLI'
    cleanupPreference: 'Always'
    runOnce: true
    scriptContent: loadTextContent('create-kv-secrets.sh')
    arguments: arguments
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
    timeout: 'PT5M'
    userAssignedIdentities: {
      '${managedIdentityResource.id}': {}
    }
  }
}
