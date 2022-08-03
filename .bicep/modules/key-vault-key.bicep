@description('The name of the existing key vault resource')
param keyVaultName string

@description('Key Vault Key settings object')
param settings object = {
  name: ''
  keyType: 'RSA'
  keyOps: []
  keySize: 2048
  curveName: ''
}

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' = {
  parent: vault
  name: settings.name
  properties: {
    kty: settings.keyType
    keyOps: settings.keyOps
    keySize: settings.keySize
    curveName: settings.curveName
  }
}

output id string = key.id
output name string = key.name
output proxyKey object = key.properties
