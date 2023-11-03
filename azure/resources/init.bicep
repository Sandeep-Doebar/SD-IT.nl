param config object
param location string = resourceGroup().location

module managedIdentity './init-modules/managed-identity/main.bicep' = if(contains(config, 'managedIdentities')){
  name: 'main-managed-identities'
  params: {
    location: location
    config: config
   }
}

module automationAccount './init-modules/automation-account/main.bicep' = if(contains(config, 'automationAccounts')){
  name: 'main-automation-accounts'
  params: {
    location: location
    config: config
  }
}
