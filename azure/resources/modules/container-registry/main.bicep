param name string
param sku string
param adminUserEnabled bool
param anonymousPullEnabled bool
param managedIdentities array
param location string = resourceGroup().location

module acr 'modules/acr.bicep' = {
  name: name
  params: {
    location: location
    name: name
    sku: sku
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    managedIdentitiesArray: managedIdentities
  }
}
