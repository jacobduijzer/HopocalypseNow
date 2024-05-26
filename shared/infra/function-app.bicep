param projectName string
param applicationName string
param location string
param uniquePostFix string
param hostingPlanName string
param appiName string
param kvName string
param saConnectionStringName string
param cosmosDbDatabaseName string
param scopeResourceGroup string

param extraAppSettings object = {
   PlaceholderSetting: ''
}

var functionAppName = 'fn-${projectName}-${applicationName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(scopeResourceGroup)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appiName
  scope: resourceGroup(scopeResourceGroup)
}

var basicAppSettings = {
  AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=${saConnectionStringName} )'
  //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=${saConnectionStringName})'
  //WEBSITE_CONTENTSHARE: toLower(functionAppName)
  FUNCTIONS_EXTENSION_VERSION: '~4'
  APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
  APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString 
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
  CosmosDbDatabaseName: cosmosDbDatabaseName
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: 'DOTNET|6.0'
      alwaysOn: false
    }
    httpsOnly: true
  }
}

module appSettings 'app-settings.bicep' = {
  name: '${functionAppName}-appsettings'
  params: {
    webAppName: functionApp.name
    currentAppSettings: basicAppSettings
    extraAppSettings: extraAppSettings
  }
}

output funcName string = functionApp.name
output defaultHostName string = functionApp.properties.defaultHostName
output funcPrincipalId string = functionApp.identity.principalId
