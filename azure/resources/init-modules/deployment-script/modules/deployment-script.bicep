param name string
param location string = resourceGroup().location
param kind string
param properties object
param storage object

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storage.name
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    azCliVersion: properties.azCliVersion
    timeout: properties.timeout
    retentionInterval: properties.retentionInterval
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: storageAccount.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: storageAccount.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadTextContent('../../../scripts/runbookCleanupResources.ps1')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${storage.fileName} && az storage blob upload -f ${storage.fileName} -c ${storage.containerName} -n ${storage.fileName}'
  }
}
