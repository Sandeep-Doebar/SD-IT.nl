param name string
param automationAccountName string


resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

resource schedule 'Microsoft.Automation/automationAccounts/schedules@2022-08-08' = {
  name: name
  parent: automationAccount
  properties: {
    startTime: ''
    interval: any(1)
    frequency: 'Day'
  }
}
