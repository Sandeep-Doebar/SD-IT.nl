@description('The environment prefix of the Managed Cluster resource e.g. dev, prod, etc.')
param prefix string
@description('The name of the Managed Cluster resource')
param clusterName string
@description('Resource location')
param location string
@description('Kubernetes version to use')
param tags object
@description('Log Analytics Workspace Tier')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
  'Premium'
])
param workspaceTier string
param logAnalyticsWork string = 'log-${clusterName}-${prefix}-${location}'
 
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsWork
  location: location
  properties: {
    sku: {
      name: workspaceTier
    }
  }
  tags: tags
}
