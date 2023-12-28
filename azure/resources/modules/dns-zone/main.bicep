param dnsZoneName string
param deployDNSzone bool = false
param aRecords array = []
param txtRecords array = []
param cnameRecords array = []

module dnsZones 'modules/dns-zone.bicep' = if (deployDNSzone) {
  name: 'main-${dnsZoneName}'
  params: {
    dnsZoneName: dnsZoneName
  }
}

module dnsArecord 'modules/dns-a-record.bicep' = [for (aRecord, index) in aRecords: {
  name: 'main-${dnsZoneName}-a-${index}'
  params: {
    dnsZoneName: dnsZoneName
    recordName: aRecord.recordName
    targetResourceId: aRecord.recordValue
  }
}]

module dnsTXTrecord 'modules/dns-txt-record.bicep' = [for (txtRecord, index) in txtRecords: {
  name: 'main-${dnsZoneName}-txt-${index}'
  params: {
    dnsZoneName: dnsZoneName
    recordName: txtRecord.recordName
    recordValue: txtRecord.recordValue
  }
}]

module dnsCNAMErecord 'modules/dns-cname-record.bicep' = [for (cnameRecord, index) in cnameRecords: {
  name: 'main-${dnsZoneName}-cname-${index}'
  params: {
    dnsZoneName: dnsZoneName
    recordName: cnameRecord.recordName
    recordValue: cnameRecord.recordValue
  }
}]


