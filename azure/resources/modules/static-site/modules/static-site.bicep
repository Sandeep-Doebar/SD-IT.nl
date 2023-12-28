param name string
param location string
param sku object
param customDomainName string
param keyVault object
param validationMethod string = 'dns-txt-token'


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
    buildProperties: {
      skipGithubActionWorkflowGeneration: true
    }
  }
  resource staticAppCustomDomain 'customDomains@2021-03-01' = {
    name: customDomainName
    properties: {
      validationMethod: validationMethod
    }
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

output id string = staticAppService.id
output defaultHostName string = staticAppService.properties.defaultHostname
