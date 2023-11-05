// ================ //
// Parameters       //
// ================ //

@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module logWorkspace 'modules/log-analytics-workspace.bicep' = [for (workspace, index) in config.logAnalyticsWorkspaces: {
  name: workspace.name
  params: {
    name: workspace.name
    location: location
    managedIdentityName: workspace.managedIdentity.name
    managedIdentityResourceGroupName: (contains(config.logAnalyticsWorkspaces[index].managedIdentity, 'resourceGroupName')) ? workspace.managedIdentity.resourceGroupName : ''
    dailyQuotaGb: workspace.dailyQuotaGb
    retentionInDays: workspace.retentionInDays
    linkedServices: (contains(config.logAnalyticsWorkspaces[index], 'linkedServices')) ? workspace.linkedServices : []
    solutions: (contains(config.logAnalyticsWorkspaces[index], 'solutions')) ? workspace.solutions : []
  }
}]
