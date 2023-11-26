param location string
param clusterName string
param nodeCount int
param vmSize string

resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: '${clusterName}ap'
        count: nodeCount
        vmSize: vmSize
        mode: 'System'
      }
    ]
  }
}
