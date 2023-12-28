param principalId string
param principalType string
param roleDefinitionId string
param governanceId string

resource roleAssignmentSubscription 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(governanceId,principalId,roleDefinitionId)
  properties: {
    principalType: principalType
    principalId: principalId
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
