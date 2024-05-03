param projectName string
param applicationName string
param location string
param uniquePostFix string
param hostingPlanName string
param appiName string
param storageAccountName string
param cosmosDbAccountName string
param cosmosDbDatabaseName string
param scopeResourceGroup string

param extraAppSettings [object] = [{
    name: 'PlaceholderSetting'
    value: 'test'
  }
]

var functionAppName = 'fn-${projectName}-${applicationName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(scopeResourceGroup)
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
  scope: resourceGroup(scopeResourceGroup)
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
  scope: resourceGroup(scopeResourceGroup)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appiName
  scope: resourceGroup(scopeResourceGroup)
}

var basicAppSettings = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  }
  {
    name: 'WEBSITE_CONTENTSHARE'
    value: toLower(functionAppName)
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'WEBSITE_NODE_DEFAULT_VERSION'
    value: '~14'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: applicationInsights.properties.InstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsights.properties.ConnectionString
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet'
  }
  {
    name: 'CosmosDbConnectionString'
    value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
  {
    name: 'CosmosDbDatabaseName'
    value: cosmosDbDatabaseName
  }
]

// var completeAppSettings = union(basicAppSettings, extraAppsettings)

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: union(basicAppSettings, extraAppSettings)
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: 'DOTNET|6.0'
      alwaysOn: false
    }
    httpsOnly: true
  }
}

// resource appsettings 'Microsoft.Web/sites/config@2023-01-01' = {
//   parent: functionApp
//   name: 'appsettings'
//   properties: union(functionApp.listAppSettings().properties, extraAppsettings)
// }



