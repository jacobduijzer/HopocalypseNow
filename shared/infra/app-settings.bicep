param webAppName string
param currentAppSettings [object]
param extraAppSettings [object]

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'appsettings'
  properties: union(currentAppSettings, extraAppSettings)
}
