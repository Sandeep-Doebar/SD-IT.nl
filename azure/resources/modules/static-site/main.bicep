param name string
param location string
param sku object
param keyVault object

module staticWebApp 'modules/static-site.bicep' = {
  name: name
  params: {
    name: name
    location: location
    sku: sku
    keyVault:  keyVault
  }
}
