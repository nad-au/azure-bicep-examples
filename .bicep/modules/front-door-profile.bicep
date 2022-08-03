@description('Front Door profile settings object')
param settings object = {
  name: ''
  sku: 'Standard_AzureFrontDoor'
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: settings.name
  location: 'global'
  sku: {
    name: settings.sku
  }
}

output id string = frontDoorProfile.id
output name string = frontDoorProfile.name
