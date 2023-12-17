param name string
param sku string
param allocationMethod string
param dnsLabelPrefix string
param location string = resourceGroup().location

module publicIP 'modules/public-ip.bicep' = {
  name: name
  params: {
    name: name
    location: location
    sku: sku
    allocationMethod: allocationMethod
    dnsLabelPrefix: dnsLabelPrefix
  }
}

output id string = publicIP.outputs.id
