@description('Service Bus settings object')
param settings object = {
  name: ''
  sku: 'Standard'
  tier: 'Standard'
  location: resourceGroup().location
}

@description('The name of the existing key vault resource')
param keyVaultName string

@description('The name of the secret holding the Service Bus connection string')
param keyVaultSecretName string

resource serviceBus 'Microsoft.ServiceBus/namespaces@2021-06-01-preview' = {
  name: settings.name
  location: settings.location
  sku: {
    name: settings.sku
    tier: settings.tier
  }
}

var connectionString = 'Endpoint=sb://${serviceBus.name}.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=${listKeys('${serviceBus.id}/AuthorizationRules/RootManageSharedAccessKey', serviceBus.apiVersion).primaryKey}'

module keyVaultSecretModule './key-vault-secret.bicep' = {
  name: 'keyVaultSecret'
  params: {
    settings: {
      name: keyVaultSecretName
      value: connectionString
    }
    keyVaultName: keyVaultName
  }
}

output id string = serviceBus.id
output name string = serviceBus.name
