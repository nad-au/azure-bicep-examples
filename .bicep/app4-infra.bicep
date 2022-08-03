targetScope = 'subscription'

var platformInfra = json(loadTextContent('./platform-infra.json'))
var domainInfra = json(loadTextContent('./domain-infra.json'))
var app4Infra = json(loadTextContent('./app4-infra.json'))

@description('The name of the existing platform resource group')
param platformResourceGroup string

@description('The name of the existing domain resource group')
param domainResourceGroup string

resource platformKeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: platformInfra.keyVault.name
  scope: resourceGroup(platformResourceGroup)
}

resource domainKeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: domainInfra.keyVault.name
  scope: resourceGroup(domainResourceGroup)
}

module postgresDatabaseModule './modules/postgres-flex-database.bicep' = {
  name: 'postgresDatabase'
  scope: resourceGroup(platformResourceGroup)
  params: {
    databaseServer: platformInfra.postgres.name
    settings: app4Infra.postgresDatabase
  }
}

module appModule './app4-app.bicep' = {
  name: 'appService'
  scope: resourceGroup(domainResourceGroup)
  params: {
    dockerRegistryUrl: '${platformInfra.containerRegistry.name}.azurecr.io'
    dockerRegistryUsername: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.containerRegistryUsername)
    dockerRegistryPassword: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.containerRegistryPassword)
    postgresHost: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.databaseHost)
    postgresDatabase: app4Infra.postgresDatabase.name
    postgresUsername: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.databaseUsername)
    postgresPassword: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.databasePassword)
    postgresPort: 5432
    postgresLogging: false
    postgresDisableSsl: false
    cosmosConnection: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.cosmosConnectionString)
    serviceBusConnection: domainKeyVault.getSecret(domainInfra.keyVaultSecrets.serviceBusConnectionString)
    storageConnection: domainKeyVault.getSecret(domainInfra.keyVaultSecrets.appStorageConnectionString)
    websitesPort: 8080
    appServiceSettings: app4Infra.appService
  }
}

module frontDoorEndpointModule './modules/front-door-endpoint.bicep' = {
  name: 'frontDoorEndpoint'
  scope: resourceGroup(platformResourceGroup)
  params: {
    frontDoorProfileName: platformInfra.frontDoorProfile.name
    originHostName: appModule.outputs.fqdn
    dnsZoneName: platformInfra.dnsZone.name
    settings: app4Infra.frontDoorEndpoint
  }
}
