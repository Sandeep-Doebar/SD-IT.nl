param name string
param location string
param sku object
param reposityURL string
param reposityToken string
param repositoryBranch string
param stagingEnvironmentPolicy string
param allowConfigFileUpdates bool
param appBuildCommand string



module staticWebApp 'modules/static-site.bicep' = {
  name: 'main-${name}'
  params: {
    name: name
    location: location
    sku: sku
    reposityURL: reposityURL
    reposityToken: reposityToken
    repositoryBranch: repositoryBranch
    stagingEnvironmentPolicy: stagingEnvironmentPolicy
    allowConfigFileUpdates: allowConfigFileUpdates
    appBuildCommand: appBuildCommand
  }
}
