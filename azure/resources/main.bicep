param config object
param location string = 'westeurope'

targetScope = 'subscription'

module consumptionBudgets './modules/consumption-budget/main.bicep' = [for budget in config.consumptionBudgets: {
  name: 'deploy-${budget.name}'
  params: {
    name: budget.name
    amount: budget.amount
    timeGrain: budget.timeGrain
    firstThreshold: budget.firstThreshold
    secondThreshold: budget.secondThreshold
    contactEmails: budget.contactEmails
  }
}]

resource resourceGroups 'Microsoft.Resources/resourceGroups@2021-01-01' = [for rg in config.resourceGroups: {
  name: rg
  location: location
}]

module managedIdentities './modules/managed-identity/main.bicep' = [for managedIdentity in config.managedIdentities: {
  name: 'deploy-${managedIdentity.name}'
  scope: resourceGroup(managedIdentity.resourceGroupName)
  params: {
    name: managedIdentity.name
    ownerOnResourceGroup: managedIdentity.ownerOnResourceGroup
    contributorOnSubscription: managedIdentity.contributorOnSubscription
    location: location
  }
  dependsOn:[
    resourceGroups
  ]
}]

module dnsZone './modules/dns-zone/main.bicep' = [for zone in config.dnsZones: {
  name: 'deploy-${zone.name}'
  scope: resourceGroup(zone.resourceGroupName)
  params: {
    dnsZoneName: zone.name
    deployDNSzone: contains(zone, 'deployDNSzone') ? zone.deployDNSzone : false
    aRecords: contains(zone, 'aRecords') ? zone.aRecords : []
    txtRecords: contains(zone, 'txtRecords') ? zone.txtRecords : []
    cnameRecords: contains(zone, 'cnameRecords') ? zone.cnameRecords : []
  }
  dependsOn:[
    resourceGroups
  ]
}]

module keyVaults './modules/keyVault/main.bicep' = [for keyvault in config.keyVaults: {
  name: 'deploy-${keyvault.name}'
  scope: resourceGroup(keyvault.resourceGroupName)
  params: {
    name: keyvault.name
    sku: keyvault.sku
    publicNetworkAccess: !(contains(keyvault, 'publicNetworkAccess')) ? 'Enabled' : keyvault.publicNetworkAccess
    managedIdentities: keyvault.managedIdentities
    aadObjects: keyvault.aadObjects
    location: location
  }
  dependsOn: [
    resourceGroups
  ]
}]

module storageAccounts './modules/storage-account/main.bicep' = [for sa in config.storageAccounts: {
  name: 'deploy-${sa.name}'
  scope: resourceGroup(sa.resourceGroupName)
  params: {
    name: sa.name
    location: location
    containerName: sa.containerName
    kind: sa.kind
    sku: sa.sku
   }
   dependsOn:[
    resourceGroups
  ]
}]

module deploymentScripts './modules/deployment-script/main.bicep' = [for script in config.deploymentScripts: {
  name: 'deploy-${script.name}'
  scope: resourceGroup(script.resourceGroupName)
  params: {
    name: script.name
    type: script.type
    location: location
    kind: script.kind
    identity: (contains(script, 'identity')) ? script.identity : {}
    properties: script.properties
    storageAccount: (contains(script, 'storageAccount')) ? script.storageAccount : {}
  }
  dependsOn:[
    storageAccounts
  ]
}]

module automationAccount './modules/automation-account/main.bicep' = [for account in config.automationAccounts: {
  name: 'deploy-${account.name}'
  scope: resourceGroup(account.resourceGroupName)
  params: {
    name: account.name
    sku: account.sku
    managedIdentity: account.managedIdentity
    runbook: account.runbook
    location: location
  }
  dependsOn:[
    deploymentScripts
  ]
}]

module staticWebApp './modules/static-site/main.bicep' = [for site in config.staticSites: {
  name: 'deploy-${site.name}'
  scope: resourceGroup(site.resourceGroupName)
  params: {
    name: site.name
    location: location
    customDomain: site.customDomain
    sku: site.sku
    keyVault: site.keyVault
    identity: site.identity
  }
  dependsOn:[
    resourceGroups
    dnsZone
  ]
}]
