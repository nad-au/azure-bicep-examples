@description('Log Analytics settings object')
param settings object = {
  name: ''
  sku: 'PerGB2018'
  retentionInDays: 30
  location: resourceGroup().location
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: settings.name
  location: settings.location
  properties: any({
    retentionInDays: settings.retentionInDays
    features: {
      searchVersion: 1
    }
    sku: {
      name: settings.sku
    }
  })
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
