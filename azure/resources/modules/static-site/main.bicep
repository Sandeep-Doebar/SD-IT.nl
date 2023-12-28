param name string
param location string
param customDomain object
param sku object
param keyVault object
param identity object

module staticWebApp 'modules/static-site.bicep' = {
  name: 'main-${name}'
  params: {
    name: name
    location: location
    sku: sku
    customDomainName: customDomain.name
    keyVault:  keyVault
  }
}

module getDNSToken '../deployment-script/main.bicep' = {
  name: 'main-getDNSToken-${name}'
  params: {
    name: '${name}-getDNSToken'
    type: 'getDNSTokenSWA'
    location: location
    identity: identity
    staticWebappName: name
    customDomainName: customDomain.name
  }
}

module validationdnsRecord '../dns-zone/main.bicep' = {
  name: 'main-validationdnsRecord-${name}'
  scope: resourceGroup(customDomain.resourceGroupName)
  params: {
    dnsZoneName: customDomain.name
    txtRecords: (getDNSToken.outputs.isReady == false) ? [
      {
        recordName: '@'
        recordValue: getDNSToken.outputs.validationToken
      } 
    ] : []
  }
  dependsOn: [
    getDNSToken
  ]  
}

module dnsRecords '../dns-zone/main.bicep' = {
  name: 'main-dnsRecords-${name}'
  scope: resourceGroup(customDomain.resourceGroupName)
  params: {
    dnsZoneName: customDomain.name
    aRecords: [
      {
        recordName: '@'
        recordValue: staticWebApp.outputs.id
      }
    ]
    cnameRecords: [
      {
        recordName: 'www'
        recordValue: staticWebApp.outputs.defaultHostName
      }
    ]
  }
}
