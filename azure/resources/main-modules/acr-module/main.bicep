@description('Required. Config object that contains the resource definitions')
param config object
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module aksCluster 'modules/registry.bicep' = [for reg in config.registries: {
  name: reg.name
  params: {
    location: location
    aksPrincipalId: aks.outputs.clusterPrincipalID
    tags: reg.tags
    clusterName: reg.clusterName

  }
}]
