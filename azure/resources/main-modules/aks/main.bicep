@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = 'westeurope'

module aks 'modules/aks-cluster.bicep' =  [for aks in config.aks: {
  name: aks.name
  params: {
    location: location
    clusterName: aks.name
    nodeCount: aks.nodeCount
    vmSize: aks.vmSize
  }
}]
