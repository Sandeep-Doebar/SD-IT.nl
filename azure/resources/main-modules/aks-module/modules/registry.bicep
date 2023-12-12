param clusterName string
param nameacr string
param tags object
param location string = resourceGroup().location
@allowed([
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
])
param roleAcrPull string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param prefix string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' existing = {
  name: 'aks-${clusterName}-${prefix}'
}



resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: nameacr
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}
 
resource assignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name:  guid(resourceGroup().id, nameacr, 'assignAcrPullToAks')
  scope: containerRegistry
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: aksCluster.properties.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleAcrPull)
  }
 
}
 
output name string = containerRegistry.name
