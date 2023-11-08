param name string
param filename string
param containerName string
param location string = resourceGroup().location
param storageName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageName
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '8.3'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageName
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../runbookDeleteResources.ps1')
      }
    ]
    scriptContent: '''
    param([string] $CONTENT)
    Write-Output $CONTENT
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['text'] = $CONTENT
  '''
  }
}
