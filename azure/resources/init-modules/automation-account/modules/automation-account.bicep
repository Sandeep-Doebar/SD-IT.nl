param name string
param location string
param managedIdentityId string
param sku string


resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    sku: {
      name: sku
    }
  }
}


output automationAccountId string = automationAccount.id
