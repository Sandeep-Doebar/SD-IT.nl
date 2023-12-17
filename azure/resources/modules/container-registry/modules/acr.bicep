param name string
param location string
param managedIdentitiesArray array = []
param sku string
param adminUserEnabled bool
param anonymousPullEnabled bool

resource managedIdentities 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = [for (identity, index) in managedIdentitiesArray :{
  name: '${identity.name}'
  scope: resourceGroup(identity.ResourceGroupName)
}]

var acrPullDefinition = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
  }
}

resource roleAssignmentAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (identity, index) in managedIdentitiesArray :{
  name: guid(containerRegistry.id, managedIdentities[index].id, acrPullDefinition)
  scope: containerRegistry
  properties: {
    principalType: 'ServicePrincipal'
    principalId: managedIdentities[index].properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', acrPullDefinition)
  }
}]
