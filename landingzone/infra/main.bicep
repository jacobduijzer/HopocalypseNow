param buildNumber string

@minLength(2)
@maxLength(8)
@description('Provide a project name for the naming of all resources')
param projectName string 

@description('Provide a location for the resources.')
param location string = 'westeurope'

@description('Provide a location for the database.')
param dbLocation string = 'northeurope'

targetScope = 'subscription'

var rgName = 'rg-${projectName}-landingzone'

module rg '../../shared/infra/resource-group.bicep' = {
  name: 'resourceGroupModule-${buildNumber}'
  params: {
    resourceGroupName: rgName
    location: location
  }
}

var uniquePostFix = uniqueString(rg.outputs.id)

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'ApplicationInsightsModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: 'CosmosDbModule-${buildNumber}'
  params: {
    projectName: projectName
    location: dbLocation
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

var order = { name: 'order', partitionKey: 'orderId'}

module cosmosDbDatabases '../../shared/infra/cosmos-db.collection.bicep' = {
  name: 'CosmosDbDatabaseModule-${buildNumber}'
  params: {
    databaseAccount: cosmosDb.outputs.cosmosDbAccountName
    databaseName: cosmosDb.outputs.cosmosDbName
    tableName: order.name
    partitionKey: order.partitionKey
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    cosmosDb
  ]
}

module serviceBus 'modules/service-bus.bicep' = {
  name: 'ServiceBusModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module appPlan '../../shared/infra/hosting-plan.bicep' = {
  name: 'AppPlanModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module storageAccount 'modules/storage-account.bicep' = {
  name: 'StorageAccountModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module functionApp '../../shared/infra/function-app.bicep' = {
  name: 'FunctionAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: 'api'
    location: location
    uniquePostFix: uniquePostFix
    hostingPlanName: appPlan.outputs.hostingPlanName
    appiName: applicationInsights.outputs.appiName
    storageAccountName: storageAccount.outputs.name
    cosmosDbAccountName: cosmosDb.outputs.cosmosDbAccountName
    scopeResourceGroup: rgName
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    applicationInsights
    appPlan
    cosmosDb
    storageAccount
  ]
}
