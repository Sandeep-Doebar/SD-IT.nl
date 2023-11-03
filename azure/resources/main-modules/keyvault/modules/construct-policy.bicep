param keyVaultName string
param permissions object
param objectId string

resource keyvaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: '${keyVaultName}/add'
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        tenantId: tenant().tenantId
        permissions: permissions
      }
    ]
  }
}
