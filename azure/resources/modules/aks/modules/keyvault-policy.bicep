param keyvaultName string
param managedIdentityName string
param managedIdentityResourceGroup string
param permissions object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
  scope: resourceGroup(managedIdentityResourceGroup)
}

resource keyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: '${keyvaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: managedIdentity.properties.principalId
        tenantId: tenant().tenantId
        permissions: permissions
      }
    ]
  }
}
