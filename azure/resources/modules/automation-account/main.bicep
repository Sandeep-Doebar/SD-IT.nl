param name string
param sku string
param managedIdentity object
param runbook object
param location string = resourceGroup().location

resource getManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentity.name
  scope: contains(managedIdentity, 'resourceGroup') ? resourceGroup(managedIdentity.resourceGroup) : resourceGroup()
}

module automationAccount 'modules/automation-account.bicep' = {
  name: name
  params: {
    name: name
    location: location
    managedIdentityId: getManagedIdentity.id
    sku: sku
  }
  dependsOn:[
    getManagedIdentity
  ]
}

module runBook 'modules/runbook.bicep' = {
  name: runbook.name
  params: {
    name: runbook.name
    automationAccountName: name
    location: location
    storageAccountName: runbook.storageAccountName
    containerName: runbook.containerName
    script: runbook.script
    scriptType: runbook.scriptType
  }
  dependsOn:[
    automationAccount
  ]
}

module schedule 'modules/schedule.bicep' = {
  name: '${runbook.name}-schedule'
  params: {
    name: runbook.schedule.name
    automationAccountName: name
    frequency: runbook.schedule.frequency
  }
  dependsOn:[
    runBook
  ]
}

module scheduleJob 'modules/job-schedule.bicep' = {
  name: '${runbook.name}-jobSchedule'
  params: {
    runbookName: runbook.name
    scheduleName: runbook.schedule.name
    automationAccountName: name
    parameters: runbook.parameters
    principalId: getManagedIdentity.properties.principalId
  }
  dependsOn:[
    schedule
  ]
}
