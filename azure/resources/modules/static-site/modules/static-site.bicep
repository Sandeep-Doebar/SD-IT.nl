param name string
param location string
param sku object
param keyVault object


//Deploy Static Web App
resource staticAppService 'Microsoft.Web/staticSites@2021-02-01' = {
  name: name
  location: location
  sku: {
    name: sku.name
    tier: sku.tier
  }
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
    allowConfigFileUpdates: true
    provider: 'None'
    enterpriseGradeCdnStatus: 'Disabled'
  }
}


module keyVaultSecretDeploymentToken '../../keyvault/modules/secrets.bicep' = {
  name: 'secretDeploymentToken-${name}'
  scope: resourceGroup(keyVault.resourceGroupName)
  params: {
    keyVaultName: keyVault.name
    secretName: '${name}-deploymentToken'
    secretValue: staticAppService.listSecrets().properties.apiKey
  }
}
