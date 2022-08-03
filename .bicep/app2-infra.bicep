targetScope = 'subscription'

var platformInfra = json(loadTextContent('./platform-infra.json'))
var domainInfra = json(loadTextContent('./domain-infra.json'))
var app2Infra = json(loadTextContent('./app2-infra.json'))

@description('The name of the existing platform resource group')
param platformResourceGroup string

@description('The name of the existing domain resource group')
param domainResourceGroup string

@description('The name and version of the docker image to deploy')
param dockerImage string

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
    settings: app2Infra.postgresDatabase
  }
}

module containerAppModule './app2-app.bicep' = {
  name: 'containerApp'
  scope: resourceGroup(domainResourceGroup)
  params: {
    dockerRegistryUrl: '${platformInfra.containerRegistry.name}.azurecr.io'
    dockerRegistryImage: dockerImage
    dockerRegistryUsername: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.containerRegistryUsername)
    dockerRegistryPassword: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.containerRegistryPassword)
    postgresHost: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.databaseHost)
    postgresDatabase: app2Infra.postgresDatabase.name
    postgresUsername: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.databaseUsername)
    postgresPassword: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.databasePassword)
    postgresPort: 5432
    postgresLogging: false
    postgresDisableSsl: false
    cosmosConnection: platformKeyVault.getSecret(platformInfra.keyVaultSecrets.cosmosConnectionString)
    serviceBusConnection: domainKeyVault.getSecret(domainInfra.keyVaultSecrets.serviceBusConnectionString)
    storageConnection: domainKeyVault.getSecret(domainInfra.keyVaultSecrets.appStorageConnectionString)
    containerAppsName: domainInfra.containerAppsEnv.name
    containerAppSettings: app2Infra.containerApp
  }
}

module frontDoorEndpointModule './modules/front-door-endpoint.bicep' = {
  name: 'frontDoorEndpoint'
  scope: resourceGroup(platformResourceGroup)
  params: {
    frontDoorProfileName: platformInfra.frontDoorProfile.name
    originHostName: containerAppModule.outputs.fqdn
    dnsZoneName: platformInfra.dnsZone.name
    settings: app2Infra.frontDoorEndpoint
  }
}
