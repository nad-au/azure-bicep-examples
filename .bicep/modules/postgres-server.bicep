@description('Postgres Server settings object')
param settings object = {
  name: ''
  username: ''
  sku: 'GP_Gen5_2'
  tier: 'basic'
  family: 'Gen5'
  size: 51200
  capacity: 2
  version: '11'
  location: resourceGroup().location
}

@secure()
@minLength(10)
@description('Postgres server admin password')
param password string

@description('PostgreSQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('The name of the existing key vault resource')
param keyVaultName string

@description('The name of the secret holding the Db Username')
@secure()
param keyVaultSecretDbUsername string

@description('The name of the secret holding the Db Password')
@secure()
param keyVaultSecretDbPassword string

@description('The name of the secret holding the Db Host')
@secure()
param keyVaultSecretDbHost string


resource database_server 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: settings.name
  location: settings.location
  sku: {
    name: settings.sku
    tier: settings.tier
    capacity: settings.capacity
    family: settings.family
  }
  properties: {
    createMode: 'Default'
    version: settings.version
    administratorLogin: settings.username
    administratorLoginPassword: password
    storageProfile: {
      storageMB: settings.size
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
  }
}

module secretDbUser './key-vault-secret.bicep' = {
  name: 'secretDbUser'
  params: {
    settings: {
      name: keyVaultSecretDbUsername
      value: settings.username
    }
    keyVaultName: keyVaultName
  }
}

module secretDbPassword './key-vault-secret.bicep' = {
  name: 'secretDbPassword'
  params: {
    settings: {
      name: keyVaultSecretDbPassword
      value: password
    }
    keyVaultName: keyVaultName
  }
}

module secretDbHost './key-vault-secret.bicep' = {
  name: 'secretDbHost'
  params: {
    settings: {
      name: keyVaultSecretDbHost
      value: database_server.properties.fullyQualifiedDomainName
    }
    keyVaultName: keyVaultName
  }
}

output id string = database_server.id
output name string = database_server.name
