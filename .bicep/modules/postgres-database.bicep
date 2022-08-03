@description('Postgres Database settings object')
param settings object = {
  name: ''
}

@description('Name of the Postgres server resource')
param databaseServer string

resource database_server 'Microsoft.DBforPostgreSQL/servers@2017-12-01' existing = {
  name: databaseServer
}

resource database 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = {
  name: settings.name
  parent: database_server
}

output id string = database.id
output name string = database_server.name
