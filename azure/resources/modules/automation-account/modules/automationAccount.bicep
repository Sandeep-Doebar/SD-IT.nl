param name string





resource symbolicname 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: name
  location: 'string'
  identity: {
    type: 'string'
    userAssignedIdentities: {}
  }
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: true
    sku: {
       name: 'Free'
    }
  }
}
