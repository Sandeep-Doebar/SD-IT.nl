param name string
param securityRules array
param location string = resourceGroup().location

module nsgResource 'modules/nsg.bicep' = {
  name: name
  params: {
    location: location
    name: name
    securityRules: securityRules
  }
}
