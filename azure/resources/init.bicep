param config object
param location string = resourceGroup().location
module managedIdentity './init-modules/managed-identity/main.bicep' = if(contains(config, 'managedIdentities')){
  name: 'init-managed-identities'
  params: {
    location: location
    config: config
   }
}

module storageAccount './init-modules/storage-account/main.bicep' = if(contains(config, 'storageAccounts')){
  name: 'init-storage-accounts'
  params: {
    location: location
    config: config
   }
}

module DeploymentScript './init-modules/deployment-script/main.bicep' = if(contains(config, 'deploymentScripts')){
  name: 'init-DeploymentScript-accounts'
  params: {
    location: location
    config: config
  }
  dependsOn:[
    storageAccount
  ]
}

module automationAccount './init-modules/automation-account/main.bicep' = if(contains(config, 'automationAccounts')){
  name: 'init-automation-accounts'
  params: {
    location: location
    config: config
  }
  dependsOn:[
    DeploymentScript
  ]
}

