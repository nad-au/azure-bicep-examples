targetScope = 'subscription'

var platformInfra = json(loadTextContent('./platform-infra.json'))
var domainInfra = json(loadTextContent('./domain-infra.json'))

@description('The name of the existing platform resource group')
param platformResourceGroup string

@description('The name of the existing domain resource group')
param domainResourceGroup string

module keyvaultModule './modules/key-vault.bicep' = {
  name: 'keyvault'
  scope: resourceGroup(domainResourceGroup)
  params: {
    settings: domainInfra.keyVault
  }
}

module storageModule './modules/storage.bicep' = {
  name: 'storage'
  scope: resourceGroup(domainResourceGroup)
  params: {
    settings: domainInfra.storage
    keyVaultName: keyvaultModule.outputs.name
    keyVaultSecretName: domainInfra.keyVaultSecrets.appStorageConnectionString
  }
}

module cosmosSqlDatabaseModule './modules/cosmos-sql-database.bicep' = {
  name: 'cosmosDatabase'
  scope: resourceGroup(platformResourceGroup)
  params: {
    cosmosAccountName: platformInfra.cosmos.name
    settings: domainInfra.cosmosSqlDatabase
  }
}

module cosmosSqlContainerModule './modules/cosmos-sql-container.bicep' = {
  name: 'cosmosContainer'
  scope: resourceGroup(platformResourceGroup)
  params: {
    cosmosAccountName: platformInfra.cosmos.name
    cosmosDbName: domainInfra.cosmosSqlDatabase.name
    settings: domainInfra.cosmosSqlContainer
  }
}

module servicebusModule './modules/servicebus.bicep' = {
  name: 'servicebus'
  scope: resourceGroup(domainResourceGroup)
  params: {
    settings: domainInfra.servicebus
    keyVaultName: keyvaultModule.outputs.name
    keyVaultSecretName: domainInfra.keyVaultSecrets.serviceBusConnectionString
  }
}

module containerAppsEnvModule './modules/container-apps-env.bicep' = {
  name: 'containerAppsEnv'
  scope: resourceGroup(domainResourceGroup)
  params: {
    infraResourceGroup: platformResourceGroup
    logAnalyticsName: platformInfra.logAnalytics.name
    settings: domainInfra.containerAppsEnv
  }
}

output keyVaultName string = keyvaultModule.outputs.name
