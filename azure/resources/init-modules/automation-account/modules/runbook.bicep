param name string
param automationAccountName string
param location string
param storageAccountName string
param containerName string
param script string
param scriptType string


resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

resource runbook 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  parent: automationAccount
  name: name
  location: location
  properties: {
    runbookType: scriptType
    logProgress: true
    logVerbose: true
    publishContentLink: {
      uri: 'https://${storageAccountName}.blob.${environment().suffixes.storage}/${containerName}/${script}'
    }
  }
}



