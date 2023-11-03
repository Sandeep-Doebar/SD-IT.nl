param config object
param location string = resourceGroup().location

module automationAccount './modules/automation-account/main.bicep' = if(contains(config, 'automationAccounts')){
  name: 'main-automation-accounts'
  params: {
    location: location
    config: config
  }
}
