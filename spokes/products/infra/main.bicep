param buildNumber string

@minLength(2)
@maxLength(8)
@description('Provide a project name for the naming of all resources')
param projectName string 

@description('Provide a location for the resources.')
param location string = 'westeurope'

targetScope = 'subscription'

var rgName = 'rg-${projectName}-products'
var rgLandingZoneName = 'rg-${projectName}-landingzone'

// existing resources
resource rgLandingZone 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: rgLandingZoneName
}

var uniquePostFix = uniqueString(rgLandingZone.id)
var kvName = 'kv-${projectName}-${uniquePostFix}'

// end existing resources

module rg '../../../shared/infra/resource-group.bicep' = {
  name: 'resourceGroupModule-${buildNumber}'
  params: {
    resourceGroupName: rgName
    location: location
  }
}

module storageAccount '../../../shared/infra/storage-account.bicep' = {
  name: 'StorageAccountModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    kvName: kvName
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}



var beer = { name: 'beers', partitionKey: 'beerId'}
var breweries = { name: 'breweries', partitionKey: 'breweryId' }
var styles = { name: 'styles', partitionKey: 'styleId' }

var collections = [beer, breweries, styles]
var databaseName = 'db-${projectName}-${uniqueString(rgLandingZone.id)}'

module cosmosDbDatabases '../../../shared/infra/cosmos-db.collection.bicep' = [for collection in collections: {
  name: 'CosmosDbDatabaseModule-${collection.name}-${buildNumber}'
  params: {
    databaseAccount: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    databaseName: databaseName
    tableName: collection.name
    partitionKey: collection.partitionKey
  }
  scope: resourceGroup(rgLandingZoneName)
}]

module functionApp '../../../shared/infra/function-app.bicep' = {
  name: 'FunctionAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: 'api'
    location: location
    uniquePostFix: uniqueString(rg.outputs.id)
    hostingPlanName: 'plan-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZoneName
    extraAppSettings: {
      //AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
      // TEMP WORKAROUND, ISSUE WITH FUNCTION APP DEPLOYMENT
      AzureWebJobsStorage: storageAccount.outputs.connectionString
      WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
      //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
      // TEMP WORKAROUND, ISSUE WITH FUNCTION APP DEPLOYMENT
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccount.outputs.connectionString
      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=appi-connection-string)'
      CosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=cosmosdb-connection-string)'
      CosmosDbDatabaseName: databaseName
      ServiceBusConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sbns-full-connection-string)'
    }
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    storageAccount
    rg
  ]
}

// module webApp '../../../shared/infra/web-app.bicep' = {
//   name: 'WebAppModule-${buildNumber}'
//   params: {
//     projectName: projectName
//     applicationName: 'cms'
//     location: location
//     uniquePostFix: uniqueString(rg.outputs.id)
//     hostingPlanName: 'plan-${projectName}-${uniqueString(rgLandingZone.id)}'
//     appiName: 'appi-${projectName}-${uniqueString(rgLandingZone.id)}'
//     cosmosDbAccountName: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
//     cosmosDbDatabaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
//     scopeResourceGroup: rgLandingZone.name
//     extraAppSettings: [{
//       name: 'ProductsApiAddress'
//       value: 'https://${functionApp.outputs.defaultHostName}/api'
//     }]
//   }
//   scope: resourceGroup(rgName)
//   dependsOn: [
//     rg
//   ]
// }

// TODO: Write config to existing app
// var functionAppName = 'fn-hn-api-${uniqueString(rgLandingZone.id)}'
// resource landingZoneFunctionApp 'Microsoft.Web/sites@2023-12-01' existing = {
//   name: functionAppName
//   scope: resourceGroup(rgLandingZone.name)
// }

// module appSettings '../../../shared/infra/app-settings.bicep' = {
//   name: 'AppSettingsUpdate-${buildNumber}'
//   params: {
//     webAppName: functionAppName
//     currentAppSettings: list(resourceId('Microsoft.Web/sites/config', landingZoneFunctionApp.name, 'appsettings'), '2023-12-01').properties
//     extraAppSettings: {
//       ProductsApiUrl: 'https://${functionApp.outputs.defaultHostName}/api'
//     }
//   }
//   scope: resourceGroup(rgLandingZone.name)
// }



