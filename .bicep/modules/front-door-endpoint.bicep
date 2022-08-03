@description('Front Door endpoint settings object')
param settings object = {
  name: ''
  originGroupName: ''
  originName: ''
  routeName: ''
  hostName: ''
  cname: ''
  apex: false
}

@description('Name of the Front Door profile resource')
param frontDoorProfileName string

@description('Name of the Azure DNS Zone resource')
param dnsZoneName string

@description('FQDN of origin eg. app service or container app endpoint')
param originHostName string

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' existing = {
  name: frontDoorProfileName
}

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: dnsZoneName
}

resource customDomain 'Microsoft.Cdn/profiles/customDomains@2021-06-01' = {
  name: replace(settings.hostName, '.', '-')
  parent: frontDoorProfile
  properties: {
    azureDnsZone: {
      id: dnsZone.id
    }
    hostName: settings.hostName
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
    }
  }
}

resource validationApexTxtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = if (settings.apex) {
  parent: dnsZone
  name: '_dnsauth'
  properties: {
    TTL: 360
    TXTRecords: [
      {
        value: [
          customDomain.properties.validationProperties.validationToken
        ]
      }
    ]
  }
}

resource validationTxtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = if (!settings.apex) {
  parent: dnsZone
  name: '_dnsauth.${settings.cname}'
  properties: {
    TTL: 360
    TXTRecords: [
      {
        value: [
          customDomain.properties.validationProperties.validationToken
        ]
      }
    ]
  }
}

resource aliasRecord 'Microsoft.Network/dnsZones/A@2018-05-01' = if (settings.apex) {
  parent: dnsZone
  name: '@'
  properties: {
    TTL: 360
    targetResource: {
      id: frontDoorEndpoint.id
    }
  }
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = if (!settings.apex) {
  parent: dnsZone
  name: settings.cname
  properties: {
    TTL: 360
    targetResource: {
      id: frontDoorEndpoint.id
    }
  }
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2021-06-01' = {
  name: settings.name
  parent: frontDoorProfile
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource frontDoorOriginGroup 'Microsoft.Cdn/profiles/originGroups@2021-06-01' = {
  name: settings.originGroupName
  parent: frontDoorProfile
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
  }
}

resource frontDoorOrigin 'Microsoft.Cdn/profiles/originGroups/origins@2021-06-01' = {
  name: settings.originName
  parent: frontDoorOriginGroup
  properties: {
    hostName: originHostName
    httpPort: 80
    httpsPort: 443
    originHostHeader: originHostName
    priority: 1
    weight: 1000
  }
}

resource frontDoorRoute 'Microsoft.Cdn/profiles/afdEndpoints/routes@2021-06-01' = {
  name: settings.routeName
  parent: frontDoorEndpoint
  dependsOn: [
    frontDoorOrigin // This explicit dependency is required to ensure that the origin group is not empty when the route is created.
  ]
  properties: {
    customDomains: [
      {
        id: customDomain.id
      }
    ]
    originGroup: {
      id: frontDoorOriginGroup.id
    }
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
}

output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
