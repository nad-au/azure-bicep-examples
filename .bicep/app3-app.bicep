@description('')
param dockerRegistryUrl string

@description('')
@secure()
param dockerRegistryUsername string

@description('')
@secure()
param dockerRegistryPassword string

@description('')
@secure()
param postgresHost string

@description('')
param postgresDatabase string

@description('')
@secure()
param postgresUsername string

@description('')
@secure()
param postgresPassword string

@description('')
param postgresPort int

@description('')
param postgresLogging bool

@description('')
param postgresDisableSsl bool

@description('')
@secure()
param cosmosConnection string

@description('')
@secure()
param serviceBusConnection string

@description('')
@secure()
param storageConnection string

@description('')
param websitesPort int

@description('App Service settings object')
param appServiceSettings object = {
  name: ''
  planName: ''
  sku: ''
  location: ''
}

resource servicePlan 'microsoft.web/serverFarms@2021-03-01' = {
  name: appServiceSettings.planName
  location: appServiceSettings.location
  sku: {
    name: appServiceSettings.sku
  }
  properties: {
    reserved: true
  }
  kind: 'linux'
}

resource appService 'microsoft.web/sites@2021-03-01' = {
  name: appServiceSettings.name
  location: appServiceSettings.location
  properties: {
    siteConfig: {
      appSettings:  [
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryUsername
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryPassword
        }
        {
          name: 'DATABASE_USER'
          value: postgresUsername
        }
        {
          name: 'DATABASE_PASSWORD'
          value: postgresPassword
        }
        {
          name: 'DATABASE_NAME'
          value: postgresDatabase
        }
        {
          name: 'DATABASE_PORT'
          value: '${postgresPort}'
        }
        {
          name: 'DATABASE_HOST'
          value: postgresHost
        }
        {
          name: 'DATABASE_LOGGING'
          value: '${postgresLogging}'
        }
        {
          name: 'DATABASE_DISABLE_SSL'
          value: '${postgresDisableSsl}'
        }
        {
          name: 'COSMOS_CONNECTION'
          value: cosmosConnection
        }
        {
          name: 'SERVICEBUS_CONNECTION'
          value: serviceBusConnection
        }
        {
          name: 'STORAGE_CONNECTION'
          value: storageConnection
        }
        {
          name: 'WEBSITES_PORT'
          value: '${websitesPort}'
        }
      ]
      linuxFxVersion: 'NODE|16-lts'
    }
    serverFarmId: servicePlan.id
  }
}

output fqdn string = '${appService.name}.azurewebsites.net'
