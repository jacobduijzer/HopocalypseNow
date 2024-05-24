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
param kvName string

param extraAppSettings object = {
   PlaceholderSetting: ''
}

var functionAppName = 'fn-${projectName}-${applicationName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(scopeResourceGroup)
}
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = {
  name: storageAccountName
  scope: resourceGroup(scopeResourceGroup)
}

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' existing = {
  name: cosmosDbAccountName
  scope: resourceGroup(scopeResourceGroup)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appiName
  scope: resourceGroup(scopeResourceGroup)
}

var basicAppSettings = {
  AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
  WEBSITE_CONTENTSHARE: toLower(functionAppName)
  FUNCTIONS_EXTENSION_VERSION: '~4'
  APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsights.properties.InstrumentationKey
  APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString 
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
  //CosmosDbConnectionString: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
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

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
}

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: 'add'
  parent: kv
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId 
        objectId: functionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
      }
    ]
  }
}

output defaultHostName string = functionApp.properties.defaultHostName



