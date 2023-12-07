param config object
@description('The location of the resources')
param location string = resourceGroup().location
param clusterPrincipalID string
param sshPublicKey string

module azks './main-modules/aks-module/main.bicep' = if (contains(config, 'akservices')){
  name: 'main-aks'
  params: {
    location: location
    config: config
    clusterPrincipalID: clusterPrincipalID
    sshPublicKey: sshPublicKey
  }
}
 

