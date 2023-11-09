param name string
param automationAccountName string
//param runBookName string
//param Schedulename string

resource automationAccount 'Microsoft.Automation/automationAccounts@2022-08-08' existing = {
  name: automationAccountName
}

resource scheduleJob 'Microsoft.Automation/automationAccounts/jobSchedules@2022-08-08' = {
  name: name
  parent: automationAccount
  properties: {
    runbook: {
      name: 'teknologi-eur1-tst-rb-deleteresources'
    }
    schedule: {
      name: 'teknologi-eur1-tst-s-deleteresources'
    }
  }
}
