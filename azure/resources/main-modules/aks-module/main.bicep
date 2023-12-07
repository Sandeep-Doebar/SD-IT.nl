@description('Required. Config object that contains the resource definitions')
param config object
@description('Optional. Location for all resources.')
param location string = resourceGroup().location
param clusterPrincipalID string
param sshPublicKey string
module vnet 'modules/vnet.bicep' = [for vn in config.vnets: {
  name: vn.name
  params: {
    location: location
    prefix: vn.prefix
    clusterName: vn.clusterName
    vnetAddressPrefixes: vn.vnetAddressPrefixes
    subnetAddressPrefix: vn.subnetAddressPrefix
    tags: vn.tags
  }
}]

module logAnalyticsWorkspace 'modules/workspace.bicep' = [for ws in config.workSpaces: {
  name: ws.name
  params: {
    location: location
    workspaceTier: ws.workspaceTier
    prefix: ws.prefix
    clusterName: ws.clusterName 
    tags: ws.tags
  }
  dependsOn: [
    vnet    
  ]
}]

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
    sshPublicKey: sshPublicKey
    serviceCidr: aks.serviceCidr
    dnsServiceIP: aks.dnsServiceIP
    dockerBridgeCidr: aks.dockerBridgeCidr
    networkPlugin: aks.networkPlugin
    enableAutoScaling: aks.enableAutoScaling
  }
  dependsOn: [
    logAnalyticsWorkspace    
  ]
}]



module acr 'modules/registry.bicep' = [for reg in config.registries: {
  name: reg.name
  params: {
    location: location
    prefix: reg.prefix
    clusterPrincipalID: clusterPrincipalID
    tags: reg.tags
    clusterName: reg.clusterName

  }
  dependsOn: [
    aksCluster    
  ]
}]
