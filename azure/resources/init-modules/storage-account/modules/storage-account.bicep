param name string
param sku string
param kind string
param location string
param containerName string

// Create storages
resource storageAccounts 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
  allowBlobPublicAccess: true
  publicNetworkAccess: 'Enabled'
  }
}

// Create blob service
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  name: 'default'
  parent: storageAccounts
}

// Create container
resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: containerName
  parent: blobServices
  properties: {
    publicAccess: 'Container'
    metadata: {}
  }
}
