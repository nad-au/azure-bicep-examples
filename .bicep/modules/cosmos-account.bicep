@description('Cosmos Account settings object')
param settings object = {
  name: ''
  kind: 'GlobalDocumentDB'
  databaseAccountOfferType: 'Standard'
  defaultConsistencyLevel: 'Session'
  capabilities: 'EnableServerless'
  location: resourceGroup().location
}

@description('The name of the existing key vault resource')
param keyVaultName string

@description('The name of the secret holding the Cosmos connection string')
@secure()
param keyVaultSecretConnectionString string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' = {
  name: settings.name
  location: settings.location
  kind: settings.kind
  properties: {
    databaseAccountOfferType: settings.databaseAccountOfferType
    consistencyPolicy: {
      defaultConsistencyLevel: settings.defaultConsistencyLevel
    }
    locations: [
      {
        locationName: settings.location
      }
    ]
    capabilities: [
      {
        name: settings.capabilities
      }
    ]
  }
}

module secretConnection './key-vault-secret.bicep' = {
  name: 'secretConnection'
  params: {
    settings: {
      name: keyVaultSecretConnectionString
      value: cosmosAccount.listKeys().primaryMasterKey
    }
    keyVaultName: keyVaultName
  }
}

output id string = cosmosAccount.id
output name string = cosmosAccount.name
output endpoint string = cosmosAccount.properties.documentEndpoint
