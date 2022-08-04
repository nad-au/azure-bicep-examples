@secure()
@minLength(10)
param postgresPassword string

var platformInfra = json(loadTextContent('./platform-infra.json'))

module registryModule './modules/container-registry.bicep' = {
  name: 'registry'
  params: {
    settings: platformInfra.containerRegistry
    keyVaultName: keyvaultModule.outputs.name
    keyVaultSecretUsername: platformInfra.keyVaultSecrets.containerRegistryUsername
    keyVaultSecretPassword: platformInfra.keyVaultSecrets.containerRegistryPassword
  }
}

module keyvaultModule './modules/key-vault.bicep' = {
  name: 'keyvault'
  params: {
    settings: platformInfra.keyVault
  }
}

module cosmosAccountModule './modules/cosmos-account.bicep' = {
  name: 'cosmosAccount'
  params: {
    settings: platformInfra.cosmos
    keyVaultName: keyvaultModule.outputs.name
    keyVaultSecretConnectionString: platformInfra.keyVaultSecrets.cosmosConnectionString
  }
}

module postgresServerModule './modules/postgres-flex-server.bicep' = {
  name: 'postgresServer'
  params: {
    settings: platformInfra.postgresFlex
    password: postgresPassword
    keyVaultName: keyvaultModule.outputs.name
    keyVaultSecretDbUsername: platformInfra.keyVaultSecrets.databaseUsername
    keyVaultSecretDbPassword: platformInfra.keyVaultSecrets.databasePassword
    keyVaultSecretDbHost: platformInfra.keyVaultSecrets.databaseHost
  }
}

module logAnalyticsModule './modules/log-analytics.bicep' = {
  name: 'logAnalytics'
  params: {
    settings: platformInfra.logAnalytics
  }
}

module dnsZoneModule './modules/dns-zone.bicep' = {
  name: 'dnsZone'
  params: {
    settings: platformInfra.dnsZone
  }
}

module frontDoorProfileModule './modules/front-door-profile.bicep' = {
  name: 'frontDoorProfile'
  params: {
    settings: platformInfra.frontDoorProfile
  }
}

output keyVaultName string = keyvaultModule.outputs.name
