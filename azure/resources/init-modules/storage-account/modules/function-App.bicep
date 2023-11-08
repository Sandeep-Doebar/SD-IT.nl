param storageAccountName string 
param name string
param location string
// Get a reference to the existing storage
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

output name string = storageAccount.name

// Create the function app
resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  kind: 'functionapp'
    properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'store_key'
          // Here we can securely get the access key
          value: 'AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
      ]
    }
  }
}
