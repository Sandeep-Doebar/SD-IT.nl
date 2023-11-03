module logAnalyticsWorkspace 'br/registry:log-analytics-workspace:v0.1' = if(contains(config, 'logAnalyticsWorkspaces')){
  name: 'main-log-analytics-workspace'
  params: {
    location: location
    config: config
  }
}
