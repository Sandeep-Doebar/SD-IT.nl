param name string
param sku string
param publicNetworkAccess string
param managedIdentities array
param aadObjects array
param location string = resourceGroup().location

module keyVault 'modules/keyvault.bicep' = {
  name: name
  params: {
    name: name
    location: location
    sku: sku
    publicNetworkAccess: publicNetworkAccess
  }
}

module accessPolicy 'modules/keyvault-policy.bicep' = {
  name: '${name}-policy'
  params: {
    keyvaultName: name
    managedIdentities: managedIdentities
    aadObjects: aadObjects
    permissionsGet: {
      keys: [
        'get'
        'list'
      ]      
      secrets: [
        'get'
        'list'
      ]
      certificates: [
        'get'
        'getissuers'
        'list'
        'listissuers'
      ]
    }
    permissionsManage: {
      keys: [
        'get'
        'list'
        'create'
        'update'
      ]
      secrets: [
        'get'
        'list'
        'set'
      ]
      certificates: [
        'get'
        'getissuers'
        'list'
        'listissuers'
        'create'
        'update'
      ]
    }
  }
  dependsOn: [
    keyVault
  ]
}
