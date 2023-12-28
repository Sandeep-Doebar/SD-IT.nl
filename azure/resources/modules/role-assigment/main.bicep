param principalId string
param principalType string
param roleDefinitionId string
param subscription bool = false


module roleAssignmentResourceGroup './modules/role-assignment-resourcegroup.bicep' = if(subscription == false ){
  name: 'main-${principalId}-resourceGroup'
  params: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
    governanceId: resourceGroup().id
  }
}

module roleAssignmentSubscription'./modules/role-assignment-subscription.bicep' = if(subscription == true ){
  name: 'main-${principalId}-subscription'
  scope: az.subscription()
  params: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: roleDefinitionId
    governanceId: az.resourceGroup().id
  }
}
