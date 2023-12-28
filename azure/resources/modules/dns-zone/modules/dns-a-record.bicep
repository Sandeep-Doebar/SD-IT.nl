param dnsZoneName string
param recordName string = ''
param targetResourceId string

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: dnsZoneName
}

resource endpointDNS 'Microsoft.Network/dnsZones/A@2018-05-01' = {
  name: recordName
  parent: dnsZone
  properties: {
    TTL: 3600
    targetResource: {
      id: targetResourceId
    }
  }
}
