@description('Container Registry settings object')
param settings object = {
  name: ''
  sku: 'Basic'
  location: resourceGroup().location
}

@description('The name of the existing key vault resource')
param keyVaultName string

@description('The name of the secret holding the Username')
@secure()
param keyVaultSecretUsername string

@description('The name of the secret holding the Password')
@secure()
param keyVaultSecretPassword string

resource registry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: settings.name
  location: settings.location 
  sku: {
    name: settings.sku
  }
  properties: {
    adminUserEnabled: true
  }
}

var credentials = registry.listCredentials()

module secretUser './key-vault-secret.bicep' = {
  name: 'secretUser'
  params: {
    settings: {
      name: keyVaultSecretUsername
      value: credentials.username
    }
    keyVaultName: keyVaultName
  }
}

module secretPassword './key-vault-secret.bicep' = {
  name: 'secretPassword'
  params: {
    settings: {
      name: keyVaultSecretPassword
      value: credentials.passwords[0].value
    }
    keyVaultName: keyVaultName
  }
}

output id string = registry.id
output name string = registry.name
