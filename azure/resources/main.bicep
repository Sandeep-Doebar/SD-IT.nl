param config object
@description('The location of the resources')
param location string = resourceGroup().location
module vnet './main-modules/vnet-module/main.bicep' = if(contains(config, 'vnets')) {
  name: 'main-vnet'
  params: {
    location: location
    config: config
  }
}

module logAnalyticsWorkspace './main-modules/workspace-module/main.bicep' = if (contains(config, 'workSpaces')) {
  name: 'main-workSpace'
  params: {
    location: location
    config: config
  }
 
  dependsOn: [
    vnet
  ]
}
 
module azks './main-modules/aks-module/main.bicep' = if (contains(config, 'akservices')){
  name: 'main-aks'
  params: {
    location: location
    config: config
  }
 
  dependsOn: [
    logAnalyticsWorkspace
  ]
}
 
module registry './main-modules/acr-module/main.bicep' = if (contains(config, 'registries')) {
  name: 'main-registry'
  params: {
    location: location
    config: config
  }
 
  dependsOn: [
    aks
  ]
}
