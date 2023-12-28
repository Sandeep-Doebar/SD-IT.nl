param name string
param location string
param ownerOnResourceGroup bool
param contributorOnSubscription bool

var ownerRoleDefinition = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var contributorRoleDefinition = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
}

resource roleAssignmentResourceGroup 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(ownerOnResourceGroup == true ){
  name: guid(managedIdentity.id, resourceGroup().id)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', ownerRoleDefinition)
  }
}

//Contributor on subscription
resource roleAssignmentSubscription 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(contributorOnSubscription == true ){
  name: guid(subscription().subscriptionId, managedIdentity.id, contributorRoleDefinition)
  properties: {
    principalType: 'ServicePrincipal'
    principalId: managedIdentity.properties.principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinition)
  }
}

output principalId string = managedIdentity.properties.principalId
