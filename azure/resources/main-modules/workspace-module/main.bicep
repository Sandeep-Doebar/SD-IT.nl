@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module logAnalyticsWorkspace 'modules/workspace.bicep' = [for ws in config.workSpaces: {
  name: ws.name
  params: {
    location: location
    workspaceTier: ws.workspaceTier
    prefix: ws.prefix
    clusterName: ws.clusterName    
    tags: ws.tags
  }
}]
