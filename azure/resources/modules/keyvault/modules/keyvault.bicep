param name string
param location string
param sku string = 'standard'
param publicNetworkAccess string = 'Enabled'

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: tenant().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableRbacAuthorization: false
    publicNetworkAccess: publicNetworkAccess
    accessPolicies: []
  }
}
