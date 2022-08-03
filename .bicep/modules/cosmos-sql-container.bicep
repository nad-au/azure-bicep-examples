@description('Cosmos SQL container settings object')
param settings object = {
  name: ''
  partitionKeyPath: ''
  partitionKeyKind: 'Hash'
}

@description('Name of the Cosmos Account resource')
param cosmosAccountName string

@description('Name of the Cosmos SQL Database resource')
param cosmosDbName string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' existing = {
  name: cosmosAccountName
}

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-04-15' existing = {
  parent: cosmosAccount
  name: cosmosDbName
}

resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-10-15' = {
  parent: cosmosDb
  name: settings.name
  properties: {
    resource: {
      id: settings.name
      partitionKey: {
        paths: [
          settings.partitionKeyPath
        ]
        kind: settings.partitionKeyKind
      }
    }
  }
}

output id string = cosmosContainer.id
output name string = cosmosContainer.name
