@description('The name of the existing Container Apps resource')
param containerAppsName string

@description('Container Apps settings object')
param settings object = {
  name: ''
  location: resourceGroup().location
  ingressExternal: true
  ingressPort: 80
  containerName: ''
  containerImage: ''
  cpu: ''
  memory: ''
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppsName
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: settings.name
  location: settings.location
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {  
      ingress: {
        external: settings.ingressExternal
        targetPort: settings.ingressPort
      }
    }
    template: {
      containers: [
        {
          name: settings.containerName
          image: settings.containerImage
          resources: {
            cpu: json(settings.cpu)
            memory: settings.memory
          }
        }
      ]
    }
  }
}

output id string = containerApp.id
output name string = containerApp.name
output fqdn string = containerApp.properties.configuration.ingress.fqdn
