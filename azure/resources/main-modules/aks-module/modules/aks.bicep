@description('The environment prefix of the Managed Cluster resource e.g. dev, prod, etc.')
param prefix string
@description('The name of the Managed Cluster resource')
param clusterName string
@description('Resource location')
param location string
@description('The VM Size to use for each node')
param nodeVmSize string
@minValue(1)
@maxValue(50)
@description('The number of nodes for the cluster.')
param nodeCount int
@maxValue(100)
@description('Max number of nodes to scale up to')
param maxNodeCount int
@description('The node pool name')
param nodePoolName string
@minValue(0)
@maxValue(1023)
@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize')
param osDiskSizeGB int
param nodeAdminUsername string
@description('Availability zones to use for the cluster nodes')
param availabilityZones array = [
  '3'
]
@description('Allow the cluster to auto scale to the max node count')
param enableAutoScaling bool
@description('SSH RSA public key for all the nodes')
@secure()
param sshPublicKey string
@description('Tags for the resources')
param tags object
@allowed([
  'azure' 
])
@description('Network plugin used for building Kubernetes network')
param networkPlugin string
@description('Cluster services IP range')
param serviceCidr string 
@description('DNS Service IP address')
param dnsServiceIP string 
@description('Docker Bridge IP range')
param dockerBridgeCidr string
param logAnalyticsWork string = '${prefix}-oms-${clusterName}-${location}'

@description('The virtual network name')
param vnetName string = '${prefix}-vnet-${clusterName}-${location}'
@description('The name of the subnet')
param subnetName string = '${prefix}-snet-${clusterName}-${location}'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01'  existing = {
  name: logAnalyticsWork
}

resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01'   existing = {
  name: vnetName
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: '${prefix}aks${clusterName}${location}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags  
  properties: {
    nodeResourceGroup: 'rg${prefix}aksnodes${clusterName}'
    dnsPrefix: '${clusterName}-dns'
    enableRBAC: true    
    agentPoolProfiles: [
      {        
        name: nodePoolName
        osDiskSizeGB: osDiskSizeGB
        osDiskType: 'Ephemeral'       
        count: nodeCount
        enableAutoScaling: enableAutoScaling
        minCount: nodeCount
        maxCount: maxNodeCount
        vmSize: nodeVmSize        
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        availabilityZones: availabilityZones
        enableEncryptionAtHost: false
        vnetSubnetID: '${vnet.id}/subnets/${subnetName}'
      }
    ]
    networkProfile: {      
      loadBalancerSku: 'standard'
      networkPlugin: networkPlugin
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIP
      dockerBridgeCidr: dockerBridgeCidr
    }

    addonProfiles: {
      azurepolicy: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }   
    }
    linuxProfile: {      
      adminUsername: nodeAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKey
          }
        ]
      }      
    }
  }
 
  dependsOn: [
    logAnalyticsWorkspace    
  ]
}
 
output controlPlaneFQDN string = aksCluster.properties.fqdn
