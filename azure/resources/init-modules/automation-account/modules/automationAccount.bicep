param name string
param location string
param sku string
param publicNetworkAccess bool




resource symbolicname 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: name
  location: location
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: publicNetworkAccess
    sku: {
       name: sku
    }
  }
}
