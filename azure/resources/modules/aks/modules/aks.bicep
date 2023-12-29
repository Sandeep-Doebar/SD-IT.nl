param name string
param location string
param apiServerIpWhitelist array
param virtualNetwork object
param managedIdentity object
param keyvault object
param publicIP object
param kubernetesVersion string
param adminAadGroupId string
param sshPublicKey string
param nodepools array

// ================== //
// Existing resources //
// ================== //

resource nodepoolSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name : '${virtualNetwork.name}/${virtualNetwork.subnet}'
  scope: !empty(virtualNetwork.resourceGroupName) ? resourceGroup(virtualNetwork.resourceGroupName) : resourceGroup()  
}

resource managedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: managedIdentity.name
  scope: !empty(managedIdentity.resourceGroupName) ? resourceGroup(managedIdentity.resourceGroupName) : resourceGroup()
}

resource outboundIp 'Microsoft.Network/publicIPAddresses@2022-07-01' existing = {
  name: publicIP.name
  scope: !empty(publicIP.resourceGroupName) ? resourceGroup(publicIP.resourceGroupName) : resourceGroup()
}

// ================== //
// Variables          //
// ================== //

var dnsPrefix = '${resourceGroup().name}-${name}'
var aksResourceGroup = 'MC_${resourceGroup().name}_${name}_${location}'

resource managedCluster 'Microsoft.ContainerService/managedClusters@2022-09-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResource.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    aadProfile: {
      adminGroupObjectIDs: [
        adminAadGroupId
      ]
      enableAzureRBAC: false
      managed: true
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
        enabled: true
        identity: {
          resourceId: resourceId(aksResourceGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', 'azurekeyvaultsecretsprovider-${name}')
        }
      }
    }
    agentPoolProfiles: [for nodepool in nodepools: union({
      name: nodepool.name
      availabilityZones: (nodepool.useAvailabilityZones) ? [
        '1'
        '2'
        '3'
      ] : []
      count: nodepool.nodeCount
      enableEncryptionAtHost: false
      enableFIPS: false
      enableNodePublicIP: false
      enableUltraSSD: false
      maxPods: 110
      mode: nodepool.type
      nodeTaints: nodepool.taints
      osDiskSizeGB: 0
      osDiskType: 'Managed'
      osSKU: nodepool.operatingSystem.sku
      osType: nodepool.operatingSystem.type
      type: 'VirtualMachineScaleSets'
      vmSize: nodepool.size
      vnetSubnetID: nodepoolSubnet.id
    }, (nodepool.autoScalingOptions.enabled) ? {
      enableAutoScaling: true
      minCount: nodepool.autoScalingOptions.minNodeCount
      maxCount: nodepool.autoScalingOptions.maxNodeCount
    } : {
      enableAutoScaling: false
    })]
    apiServerAccessProfile: {
      authorizedIPRanges: apiServerIpWhitelist
    }
    disableLocalAccounts: false
    dnsPrefix: dnsPrefix
    enableRBAC: true
    identityProfile: {
      kubeletidentity: {
        resourceId: managedIdentityResource.id
      }
    }
    linuxProfile: {
      adminUsername: 'azureuser'
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKey
          }
        ]
      }
    }
    networkProfile: {
      loadBalancerProfile: {
        outboundIPs: {
          publicIPs: [
            {
              id: outboundIp.id
            }
          ]
        }
      }
      loadBalancerSku: 'Standard'
      networkPlugin: 'azure'
      outboundType: 'loadBalancer'
    }
    nodeResourceGroup: aksResourceGroup
    oidcIssuerProfile: {
      enabled: false
    }
    storageProfile: {
      blobCSIDriver: {
        enabled: true
      }
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
  }
}

//
// Deploy keyvault accesspolicy for secrets provider driver
//
module accessPolicy 'keyvault-policy.bicep' = {
  name: 'keyvault-policy'
  scope: resourceGroup(keyvault.resourceGroupName)
  params: {
    keyvaultName: keyvault.name
    managedIdentityName: 'azurekeyvaultsecretsprovider-${name}'
    managedIdentityResourceGroup: aksResourceGroup
    permissions: {
      secrets: [
        'get'
        'list'
      ]
    }
  }
  dependsOn: [
    managedCluster
  ]
}
