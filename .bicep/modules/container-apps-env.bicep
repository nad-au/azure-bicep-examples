@description('The RG of the existing key vault resource')
param infraResourceGroup string

@description('The name of the existing log analytics resource')
param logAnalyticsName string

@description('Container Apps settings object')
param settings object = {
  name: ''
  location: resourceGroup().location
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' existing = {
  scope: resourceGroup(infraResourceGroup)
  name: logAnalyticsName
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: settings.name
  location: settings.location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

output id string = containerAppsEnvironment.id
output name string = containerAppsEnvironment.name
output domain string = containerAppsEnvironment.properties.defaultDomain
