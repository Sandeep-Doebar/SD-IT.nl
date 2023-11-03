// ================ //
// Parameters       //
// ================ //

@description('Required. Config object that contains the resource definitions')
param config object

@description('Required. Check against already existing resources in the resourcegroup')
param existingResources array = []

@description('Optional. Location for all resources.')
param location string = resourceGroup().location
  
module automationAccount 'modules/automationAccount.bicep' = [for (automationAccount, index) in config.automationAccounts: {
  name: automationAccount.name
  params: {
    location: location
    name: automationAccount.name
    sku: automationAccount.sku
    publicNetworkAccess: !(contains(config.automationAccounts[index], 'publicNetworkAccess')) ? true : automationAccount.publicNetworkAccess
  }
}]
