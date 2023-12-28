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

module roleAssignmentResourceGroup '../../role-assigment/main.bicep' = if(ownerOnResourceGroup == true ){
  name: '${name}-resourcegroup-owner'
  params: {
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: ownerRoleDefinition
    subscription: false
  }
}

//Contributor on subscription
module roleAssignmentSubscription '../../role-assigment/main.bicep' = if(contributorOnSubscription == true ){
  name: '${name}-subscription-contributor'
  params: {
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinition
    subscription: true
  }
}

output principalId string = managedIdentity.properties.principalId
