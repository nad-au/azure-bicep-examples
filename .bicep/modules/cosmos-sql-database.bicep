@description('Cosmos SQL database settings object')
param settings object = {
  name: ''
}

@description('Name of the Cosmos Account resource')
param cosmosAccountName string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' existing = {
  name: cosmosAccountName
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' = {
  parent: cosmosAccount
  name: settings.name
  properties: {
    resource: {
      id: settings.name
    }
  }
}

output id string = cosmosDb.id
output name string = cosmosDb.name
output databaseName string = settings.name
