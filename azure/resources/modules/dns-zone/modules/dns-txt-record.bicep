param dnsZoneName string
param recordName string
param recordValue string

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: dnsZoneName
}

resource txtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = {
  name: recordName
  parent: dnsZone
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [ recordValue ]
      }
    ]
  }
}
