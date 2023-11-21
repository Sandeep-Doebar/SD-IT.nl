param config object
param location string
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

