param name string
param location string
param sku object
param reposityURL string
param reposityToken string
param repositoryBranch string
param stagingEnvironmentPolicy string
param allowConfigFileUpdates bool
param appBuildCommand string = 'npm run build'

//Deploy Static Web App
resource staticAppService 'Microsoft.Web/staticSites@2021-02-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: sku
  properties:{
    provider: 'GitHub'
    repositoryUrl: reposityURL
    repositoryToken: reposityToken
    branch: repositoryBranch
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    allowConfigFileUpdates: allowConfigFileUpdates
    buildProperties: {
      appBuildCommand: appBuildCommand
    }
  }
}
