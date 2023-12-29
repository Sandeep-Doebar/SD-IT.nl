param config object
param location string = 'westeurope'

targetScope = 'subscription'

resource resourceGroups 'Microsoft.Resources/resourceGroups@2021-01-01' = [for rg in config.resourceGroups: {
  name: rg
  location: location
}]

module managedIdentities './modules/managed-identity/main.bicep' = [for managedIdentity in config.managedIdentities: {
  name: 'main-${managedIdentity.name}'
  scope: resourceGroup(managedIdentity.resourceGroupName)
  params: {
    name: managedIdentity.name
    ownerOnResourceGroup: managedIdentity.ownerOnResourceGroup
    contributorOnSubscription: managedIdentity.contributorOnSubscription
    location: location
  }
  dependsOn:[
    resourceGroups
  ]
}]

module keyVaults './modules/keyvault/main.bicep' = [for keyvault in config.keyVaults: {
  name: 'main-${keyvault.name}'
  scope: resourceGroup(keyvault.resourceGroupName)
  params: {
    name: keyvault.name
    sku: keyvault.sku
    publicNetworkAccess: !(contains(keyvault, 'publicNetworkAccess')) ? 'Enabled' : keyvault.publicNetworkAccess
    managedIdentities: keyvault.managedIdentities
    aadObjects: keyvault.aadObjects
    location: location
  }
  dependsOn: [
    resourceGroups
  ]
}]

module networkSecurityGroups './modules/network-security-group/main.bicep' = [for nsg in config.networkSecurityGroups: {
  name: 'main-${nsg.name}'
  scope: resourceGroup(nsg.resourceGroupName)
  params: {
    name: nsg.name
    location: location
    securityRules: nsg.securityRules
  }
  dependsOn: [
    resourceGroups
  ]
}]

module virtualNetworks './modules/virtual-network/main.bicep' = [for vnet in config.virtualNetworks: {
  name: 'main-${vnet.name}'
  scope: resourceGroup(vnet.resourceGroupName)
  params: {
    name: vnet.name
    addressPrefixes: vnet.addressPrefixes
    subnets: vnet.subnets
    location: location
  }
  dependsOn: [
    networkSecurityGroups
  ]
}]

module publicIPs './modules/public-ip/main.bicep' = [for pip in config.publicIPs: {
  name: 'main-${pip.name}'
  scope: resourceGroup(pip.resourceGroupName)
  params: {
    name: pip.name
    sku: pip.sku
    allocationMethod: pip.allocationMethod
    dnsLabelPrefix: pip.dnsLabelPrefix
    location: location
  }
  dependsOn: [
    resourceGroups
  ]
}]

module ACR './modules/container-registry/main.bicep' = [for acr in config.containerRegistries: {
  name: 'main-${acr.name}'
  scope: resourceGroup(acr.resourceGroupName)
  params: {
    name: acr.name
    sku: acr.sku
    adminUserEnabled: acr.adminUserEnabled
    anonymousPullEnabled: acr.anonymousPullEnabled
    managedIdentities: acr.managedIdentities
    location: location
   }
   dependsOn: [
    resourceGroups
  ]
}]

module AKS './modules/aks/main.bicep' = [for aksCluster in config.aksClusters: {
  name: 'main-${aksCluster.name}'
  scope: resourceGroup(aksCluster.resourceGroupName)
  params: {
    name: aksCluster.name
    apiServerIpWhitelist: aksCluster.apiServerIpWhitelist
    virtualNetwork: aksCluster.virtualNetwork
    managedIdentity: aksCluster.managedIdentity
    keyvault: aksCluster.keyvault
    publicIP: aksCluster.publicIP
    kubernetesVersion: aksCluster.kubernetesVersion
    adminAadGroupId: aksCluster.adminAadGroupId
    sshPublicKey: aksCluster.sshPublicKey
    nodepools: aksCluster.nodepools
    location: location
   }
   dependsOn: [
    ACR
    publicIPs
    virtualNetworks
  ]
}]

