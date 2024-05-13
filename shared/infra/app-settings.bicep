param webAppName string
param landingZoneName string
param currentAppSettings object
param extraAppSettings object

resource webApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: webAppName
  scope: resourceGroup(landingZoneName)
}

// resource siteconfig 'Microsoft.Web/sites/config@2023-12-01' = {
//   parent: webApp
//   name: 'appsettings'
//   properties: union(currentAppSettings, extraAppSettings)
// }
