param config object
param location string = 'westeurope'

targetScope = 'subscription'

module consumptionBudgets './modules/consumption-budget/main.bicep' = [for budget in config.consumptionBudgets: {
  name: 'main-${budget.name}'
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
  name: 'main-${managedIdentity.name}'
  scope: resourceGroup(managedIdentity.resourceGroupName)
  params: {
    name: managedIdentity.name
    ownerOnResourceGroup: managedIdentity.ownerOnResourceGroup
    location: location
  }
  dependsOn:[
    resourceGroups
  ]
}]

module storageAccounts './modules/storage-account/main.bicep' = [for sa in config.storageAccounts: {
  name: 'main-${sa.name}'
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
  name: 'main-${script.name}'
  scope: resourceGroup(script.resourceGroupName)
  params: {
    name: script.name
    location: location
    kind: script.kind
    properties: script.properties
    storageAccount: script.storageAccount
  }
  dependsOn:[
    storageAccounts
  ]
}]


module automationAccount './modules/automation-account/main.bicep' = [for account in config.automationAccounts: {
  name: 'main-${account.name}'
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
  name: 'main-${site.name}'
  scope: resourceGroup(site.resourceGroupName)
  params: {
    name: site.name
    location: location
    sku: site.sku
    reposityURL: site.reposityURL
    reposityToken: site.reposityToken
    repositoryBranch: site.repositoryBranch
    stagingEnvironmentPolicy: site.stagingEnvironmentPolicy
    allowConfigFileUpdates: site.allowConfigFileUpdates
    appBuildCommand: site.appBuildCommand
  }
}]
