// ================ //
// Parameters       //
// ================ //

@description('Required. Config object that contains the resource definitions')
param config object

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

module automationAccount 'modules/automation-account.bicep' = [for (account, index) in config.automationAccounts: {
  name: account.name
  params: {
    name: account.name
    location: location
    managedIdentityId: managedIdentity[index].id
    sku: account.sku
  }
  dependsOn:[
    managedIdentity
  ]
}]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = [for (account, index) in config.automationAccounts: if(contains(config.automationAccounts[index], 'managedIdentity')) {
  name: account.managedIdentity.name
  scope: contains(account.managedIdentity, 'resourceGroup') ? resourceGroup(account.managedIdentity.resourceGroup) : resourceGroup()
}]

module runBook 'modules/runbook.bicep' =  [for (account, index) in config.automationAccounts: {
  name: account.runbook.name
  params: {
    name: account.runbook.name
    automationAccountName: account.name
    location: location
  }
  dependsOn:[
    automationAccount
  ]
}]
