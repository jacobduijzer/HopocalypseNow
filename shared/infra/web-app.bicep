param projectName string
param applicationName string
param location string
param uniquePostFix string
param hostingPlanName string
param scopeResourceGroup string

param extraAppSettings object = {
   PlaceholderSetting: ''
}

var webAppName = 'app-${projectName}-${applicationName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(scopeResourceGroup)
}

var basicAppSettings = {
  WEBSITE_CONTENTSHARE: toLower(webAppName)
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  kind: 'app,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
    httpsOnly: true
  }
}

module appSettings 'app-settings.bicep' = {
  name: '${webAppName}-appsettings'
  params: {
    webAppName: appService.name
    currentAppSettings: basicAppSettings
    extraAppSettings: extraAppSettings
  }
}

output principalId string = appService.identity.principalId
