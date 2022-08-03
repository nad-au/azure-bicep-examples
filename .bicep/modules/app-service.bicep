@description('App Service settings object')
param settings object = {
  name: ''
  planName: ''
  sku: ''
  location: ''
}

resource servicePlan 'microsoft.web/serverFarms@2021-03-01' = {
  name: settings.planName
  location: settings.location
  sku: {
    name: settings.sku
  }
  properties: {
    reserved: true
  }
  kind: 'linux'
}

resource appService 'microsoft.web/sites@2021-03-01' = {
  name: settings.name
  location: settings.location
  properties: {
    siteConfig: {
      linuxFxVersion: 'NODE|16-lts'
    }
    serverFarmId: servicePlan.id
  }
}


output id string = appService.id
output name string = appService.name
output fqdn string = '${appService.name}.azurewebsites.net'
