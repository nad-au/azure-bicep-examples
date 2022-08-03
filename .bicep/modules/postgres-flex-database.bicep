@description('Postgres Database settings object')
param settings object = {
  name: ''
}

@description('Name of the Postgres server resource')
param databaseServer string

resource database_server 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' existing = {
  name: databaseServer
}

resource database 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2021-06-01' = {
  name: settings.name
  parent: database_server
}

output id string = database.id
output name string = database_server.name
