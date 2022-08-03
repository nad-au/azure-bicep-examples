@description('Postgres Server settings object')
param settings object = {
  name: ''
  username: ''
  sku: 'Standard_B1ms'
  tier: 'Burstable'
  version: '14'
  location: resourceGroup().location
}

@secure()
@minLength(10)
@description('Postgres server admin password')
param password string

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

resource database_server 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: settings.name
  location: settings.location
  sku: {
    name: settings.sku
    tier: settings.tier
  }
  properties: {
    version: settings.version
    administratorLogin: settings.username
    administratorLoginPassword: password
    storage: {
      storageSizeGB: 128
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    network: {}
    highAvailability: {
      mode: 'Disabled'
    }
    maintenanceWindow: {
      customWindow: 'Disabled'
      dayOfWeek: 0
      startHour: 0
      startMinute: 0
    }
  }
}

resource firewall 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2021-06-01' = {
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  parent: database_server
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
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
