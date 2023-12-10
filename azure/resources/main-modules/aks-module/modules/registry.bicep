
@description('The principal ID of the AKS cluster')
param clusterName string
param clusterPrincipalID string
@description('Tags for the resources')
param tags object
param location string = resourceGroup().location
@allowed([
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
])
param roleAcrPull string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
param roleDefinitionId string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleAcrPull}'
@description('The virtual network name')
param prefix string
@description('The name of the container registry')


resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' existing = {
  name: '${prefix}aks${clusterName}${location}'
}
output clusterPrincipalID string = aksCluster.properties.identityProfile.kubeletidentity.objectId


resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: '${prefix}acr${clusterName}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}
 
resource acr 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: '${prefix}acrrole${clusterName}'
  scope: containerRegistry
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: clusterPrincipalID
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
  
}
 
output name string = containerRegistry.name
