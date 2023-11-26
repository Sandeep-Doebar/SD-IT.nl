param runbookName string
param scheduleName string
param automationAccountName string
param parameters object
param principalId string

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

var identity = {
  identity: principalId
}

resource scheduleJob 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  parent: automationAccount
  name: guid(automationAccount.id, runbookName, scheduleName)
  properties: {
    runbook: {
      name: runbookName
    }
    schedule: {
      name: scheduleName
    }
    parameters: union(identity, parameters)
  }
}

