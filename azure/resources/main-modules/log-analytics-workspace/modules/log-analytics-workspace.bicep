param name string
param location string
param dailyQuotaGb int
param retentionInDays int
param managedIdentityName string
param managedIdentityResourceGroupName string
param linkedServices array = []
param solutions array = []

resource managedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
  scope: !empty(managedIdentityResourceGroupName) ? resourceGroup(managedIdentityResourceGroupName) : resourceGroup()
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityResource.id}': {}
    }
  }
  properties: {
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: retentionInDays
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
  }
}

resource workspaceLinkedServices 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = [for service in linkedServices: if(!empty(linkedServices)) {
  name: service.name
  parent: workspace
  properties: {
    resourceId: resourceId(service.resourceType, service.resourceName)
  }
}]

resource workspaceSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for (solution, index) in solutions: if(!empty(solutions)) {
  name: '${solution.name}(${workspace.name})'
  location: location
  
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: '${solution.name}(${workspace.name})'
    publisher: solution.publisher
    product: '${solution.gallery}/${solution.name}'
    promotionCode: (contains(solutions[index], 'promotionCode')) ? solution.promotionCode : ''
  }
}]

output workspaceId string = workspace.id
