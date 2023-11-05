param name string
param location string
param sku string = 'standard'
param publicNetworkAccess string = 'Enabled'
param alreadyExists bool

resource keyvaultExisting 'Microsoft.KeyVault/vaults@2022-07-01' existing = if (alreadyExists){  
  name: name
}

module keyvault 'construct-keyvault.bicep' = {
  name: 'kv-${name}'
  params: {
    name: name
    location: location
    sku: sku
    publicNetworkAccess: publicNetworkAccess
    accessPolicies: alreadyExists ? keyvaultExisting.properties.accessPolicies : []
  }

}
