@description('')
param dockerRegistryUrl string

@description('')
param dockerRegistryImage string

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

@description('The name of the existing Container Apps resource')
param containerAppsName string

@description('')
param appHost string

@description('')
param appEnv string

@description('Debug mode (should be false)')
param debug bool

@description('Container Apps settings object')
param containerAppSettings object = {
  name: ''
  location: resourceGroup().location
  ingressExternal: true
  ingressPort: 80
  containerName: ''
  cpu: ''
  memory: ''
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsName
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppSettings.name
  location: containerAppSettings.location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {  
      secrets: [
        {
          name: 'container-registry-password'
          value: dockerRegistryPassword
        }
        {
          name: 'postgres-password'
          value: postgresPassword
        }
      ]      
      registries: [
        {
          server: dockerRegistryUrl
          username: dockerRegistryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: containerAppSettings.ingressExternal
        targetPort: containerAppSettings.ingressPort
      }
    }
    template: {
      containers: [
        {
          name: containerAppSettings.containerName
          image: dockerRegistryImage
          env: [
            {
              name: 'DATABASE_USER'
              value: postgresUsername
            }
            {
              name: 'DATABASE_PASSWORD'
              secretRef: 'postgres-password'
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
              name: 'APP_HOST'
              value: appHost
            }
            {
              name: 'APP_ENV'
              value: appEnv
            }
            {
              name: 'DEBUG'
              value: '${debug}'
            }
          ]
        }
      ]
    }
  }
}

output id string = containerApp.id
output name string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
