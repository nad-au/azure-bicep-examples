@description('DNS Zone settings object')
param settings object = {
  name: ''
}

resource zone 'Microsoft.Network/dnsZones@2018-05-01' = {
  name: settings.name
  location: 'global'
}

output zone object = zone
