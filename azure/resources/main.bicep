param config object
param location string = resourceGroup().location

//module AKS './main-modules/aks/main.bicep' = if(contains(config, 'aks')){
//  name: aks.name
//  params: {
//    location: location
//    config: config
//   }
//}
