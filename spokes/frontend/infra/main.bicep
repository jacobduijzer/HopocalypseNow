param buildNumber string

@minLength(2)
@maxLength(8)
@description('Provide a project name for the naming of all resources')
param projectName string 

@description('Provide a location for the resources.')
param location string = 'westeurope'

targetScope = 'subscription'

var applicationName = 'frontend'
var rgName = 'rg-${projectName}-${applicationName}'
var rgLandingZoneName = 'rg-${projectName}-landingzone'
var kvName = 'kv-${projectName}-${uniqueString(rgLandingZone.id)}'

module rg '../../../shared/infra/resource-group.bicep' = {
  name: 'resourceGroupModule-${buildNumber}'
  params: {
    resourceGroupName: rgName
    location: location
  }
}

resource rgLandingZone 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: rgLandingZoneName
}

resource functionApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: 'fn-${projectName}-api-${uniqueString(rgLandingZone.id)}'
  scope: resourceGroup(rgLandingZoneName)
}

module webApp '../../../shared/infra/web-app.bicep' = {
  name: 'FunctionAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: applicationName
    location: location
    uniquePostFix: uniqueString(rg.outputs.id)
    hostingPlanName: 'plan-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZone.name
    extraAppSettings: {
      FrontendApiAddress: 'https://${functionApp.properties.defaultHostName}/api/graphql'
      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=appi-connection-string)'
      CosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=cosmosdb-connection-string)'
      CosmosDbDatabaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
      ServiceBusConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sbns-full-connection-string)'
    }
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
  ]
}
// var basicAppSettings = [
//   {
//     name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
//     value: applicationInsights.properties.InstrumentationKey
//   }
//   {
//     name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
//     value: applicationInsights.properties.ConnectionString
//   }
//   {
//     name: 'CosmosDbConnectionString'
//     value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
//   }
//   {
//     name: 'CosmosDbDatabaseName'
//     value: cosmosDbDatabaseName
//   }
// ]
//module functionApp '../../shared/infra/function-app.bicep' = {
//  name: 'FunctionAppModule-${buildNumber}'
//  params: {
//    projectName: projectName
//    applicationName: 'api'
//    location: location
//    uniquePostFix: uniquePostFix
//    hostingPlanName: appPlan.outputs.hostingPlanName
//    scopeResourceGroup: rgName
//    extraAppSettings: {
//      AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
//      WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
//      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
//      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${applicationInsights.outputs.secretConnectionStringName})'
//      CosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${cosmosDb.outputs.secretConnectionStringName})'
//      CosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
//      ServiceBusConnectionString: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${serviceBus.outputs.keyvaultFullConnectionStringSecretName})'
//    }
//  }
//  scope: resourceGroup(rgName)
//  dependsOn: [
//    keyVault
//    applicationInsights
//    appPlan
//    cosmosDb
//    serviceBus
//    storageAccount
//  ]
//}
//
