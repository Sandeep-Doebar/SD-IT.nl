param name string
param location string
param securityRules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-02-01' = {
  name: name
  location: location
  properties: {
    securityRules: securityRules
  }
}

output nsgId string = nsg.id
