@description('Key Vault settings object')
param settings object = {
  name: ''
  sku: 'standard'
  family: 'A'
  location: resourceGroup().location
}

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: settings.name
  location: settings.location
  properties: {
    accessPolicies: []
    enableRbacAuthorization: false
    enableSoftDelete: false
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    tenantId: subscription().tenantId
    sku: {
      name: settings.sku
      family: settings.family
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output id string = vault.id
output name string = vault.name
