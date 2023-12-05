@description('Required. Config object that contains the resource definitions')
param config object
param sshPublicKey string
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module aksCluster 'modules/aks.bicep' = [for aks in config.akservices: {
  name: aks.name
  params: {
    location: location
    prefix: aks.prefix
    clusterName: aks.clusterName
    nodeAdminUsername: aks.nodeAdminUsername
    nodeVmSize: aks.nodeVmSize
    nodeCount: aks.nodeCount
    maxNodeCount: aks.maxNodeCount
    osDiskSizeGB: aks.osDiskSizeGB
    tags: aks.tags
    nodePoolName: aks.nodePoolName
    subnetId: vnet.outputs.subnetId
    sshPublicKey: sshPublicKey
  }
}]
