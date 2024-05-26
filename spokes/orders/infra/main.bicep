param buildNumber string

@minLength(2)
@maxLength(8)
@description('Provide a project name for the naming of all resources')
param projectName string 

@description('Provide a location for the resources.')
param location string = 'westeurope'

targetScope = 'subscription'

var applicationName = 'orders'
var rgName = 'rg-${projectName}-${applicationName}'
var rgLandingZoneName = 'rg-${projectName}-landingzone'
var kvName = 'kv-${projectName}-${uniqueString(rgLandingZone.id)}'
var cosmosDbDatabaseName = 'db-${projectName}-${uniqueString(rgLandingZone.id)}'

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

var orders = { name: 'orders', partitionKey: 'orderId'}

var collections = [orders]

module cosmosDbDatabases '../../../shared/infra/cosmos-db.collection.bicep' = [for collection in collections: {
  name: 'CosmosDbDatabaseModule-${collection.name}-${buildNumber}'
  params: {
    databaseAccount: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    databaseName: cosmosDbDatabaseName
    tableName: collection.name
    partitionKey: collection.partitionKey
  }
  scope: resourceGroup(rgLandingZoneName)
}]

module serviceBusTopic '../../../shared/infra/service-bus.topic.bicep' = {
  name: 'ServiceBusTopic-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: applicationName
    uniquePostFix: uniqueString(rgLandingZone.id)
  }
  scope: rgLandingZone
}

module functionApp '../../../shared/infra/function-app.bicep' = {
  name: 'FunctionAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: applicationName
    location: location
    uniquePostFix: uniqueString(rg.outputs.id)
    hostingPlanName: 'plan-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZone.name
    extraAppSettings: {
      ServiceBusConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sbns-full-connection-string)'
      AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sa-connection-string)'
      WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sa-connection-string)'
      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=appi-connection-string)'
      CosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=cosmosdb-connection-string)'
      CosmosDbDatabaseName: cosmosDbDatabaseName
    }
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
    serviceBusTopic
  ]
}

module kvAccessPolicy '../../../shared/infra/keyvault-access-policies.bicep' = {
  name: 'KeyVaultAccessPolicy-${projectName}func-${buildNumber}'
  params: {
    keyvaultName: kvName
    permissions: [ 'get' ]
    tenantId: subscription().tenantId
    principalId: functionApp.outputs.principalId
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    functionApp
  ]
}



