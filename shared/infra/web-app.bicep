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

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET|6.0'
      //appSettings: extraAppSettings//union(basicAppSettings, extraAppSettings)
    }
  }
}

module appSettings 'app-settings.bicep' = {
  name: '${webAppName}-appsettings'
  params: {
    webAppName: appService.name
    currentAppSettings: {}
    extraAppSettings: extraAppSettings
  }
}
