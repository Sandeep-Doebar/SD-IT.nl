param name string
param location string
param sku string
param allocationMethod string
param dnsLabelPrefix string

resource pip 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: union(
    {
      publicIPAllocationMethod: allocationMethod
    },
    (empty(dnsLabelPrefix)) ? {} : {
      dnsSettings: {
        domainNameLabel: dnsLabelPrefix
      }
    }
  )
}

output id string = pip.id
