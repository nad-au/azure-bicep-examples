@description('Storage settings object')
param settings object = {
  name: ''
  kind: 'StorageV2'
  sku: 'Standard_LRS'
  location: ''
}

@description('The name of the existing key vault resource')
param keyVaultName string

@description('The name of the secret holding the Storage connection string')
param keyVaultSecretName string

resource storage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: settings.name
  location: settings.location
  kind: settings.kind
  sku: {
    name: settings.sku
  }
}

module keyVaultSecretModule './key-vault-secret.bicep' = {
  name: 'keyVaultSecret'
  params: {
    settings: {
      name: keyVaultSecretName
      value: storage.listKeys().keys[0].value
    }
    keyVaultName: keyVaultName
  }
}

output id string = storage.id
output name string = storage.name
