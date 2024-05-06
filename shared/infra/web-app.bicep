param projectName string
param applicationName string
param location string
param uniquePostFix string
param hostingPlanName string
param appiName string
// param storageAccountName string
param cosmosDbAccountName string
param cosmosDbDatabaseName string
param scopeResourceGroup string

var webAppName = 'app-${projectName}-${applicationName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-01-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(scopeResourceGroup)
}

// resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
//   name: storageAccountName
//   scope: resourceGroup(scopeResourceGroup)
// }

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' existing = {
  name: cosmosDbAccountName
  scope: resourceGroup(scopeResourceGroup)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appiName
  scope: resourceGroup(scopeResourceGroup)
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNET|6.0'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
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
    }
  }
}
