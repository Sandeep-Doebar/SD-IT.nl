param name string
param apiServerIpWhitelist array
param virtualNetwork object
param managedIdentity object
param keyvault object
param publicIP object
param kubernetesVersion string
param adminAadGroupId string
param sshPublicKey string
param nodepools array
param location string = 'westeurope'

module aks 'modules/aks.bicep' = {
  name: name
  params: {
    name: name
    location: location
    apiServerIpWhitelist: apiServerIpWhitelist
    virtualNetwork: virtualNetwork
    managedIdentity: managedIdentity
    keyvault: keyvault
    publicIP: publicIP
    kubernetesVersion: kubernetesVersion
    adminAadGroupId: adminAadGroupId
    sshPublicKey: sshPublicKey
    nodepools: nodepools
  }
  dependsOn: []
}
