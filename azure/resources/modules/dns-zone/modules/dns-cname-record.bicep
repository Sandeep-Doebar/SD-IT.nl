param dnsZoneName string
param recordName string
param recordValue string

resource dnsZone 'Microsoft.Network/dnsZones@2023-07-01-preview' existing = {
  name: dnsZoneName
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  name: recordName
  parent: dnsZone
  properties: {
    TTL: 3600
    CNAMERecord: {
      cname: recordValue
    }
  }
}
