@description('The name of the existing key vault resource')
param keyVaultName string

@description('Key Vault Secret settings object')
param settings object = {
  name: ''
  value: ''
}

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: vault
  name: settings.name
  properties: {
    value: settings.value
  }
}

output id string = secret.id
output name string = secret.name
