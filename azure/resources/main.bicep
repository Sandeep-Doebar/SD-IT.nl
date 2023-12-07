param config object
@description('The location of the resources')
param location string = resourceGroup().location
param subnetId string
param clusterPrincipalID string
param registryName string
param sshPublicKey string

module azks './main-modules/aks-module/main.bicep' = if (contains(config, 'akservices')){
  name: 'main-aks'
  params: {
    location: location
    config: config
    subnetId: subnetId
    clusterPrincipalID: clusterPrincipalID
    registryName: registryName
    sshPublicKey: sshPublicKey
  }
}
 

