param config object
param location string = resourceGroup().location

module managedIdentity 'modules/managed-identity.bicep' = [for managedIdentity in config.managedIdentities: {
  name: managedIdentity.name
  params: {
    name: managedIdentity.name
    location: location
    ownerOnResourceGroup: managedIdentity.ownerOnResourceGroup
  }
}]
