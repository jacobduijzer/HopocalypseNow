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

// collection, TODO: style / beer things

var beer = { name: 'beers', partitionKey: 'beerId'}
var breweries = { name: 'breweries', partitionKey: 'breweryId' }
var styles = { name: 'styles', partitionKey: 'styleId' }

var collections = [beer, breweries, styles]

module cosmosDbDatabases '../../../shared/infra/cosmos-db.collection.bicep' = [for collection in collections: {
  name: 'CosmosDbDatabaseModule-${collection.name}-${buildNumber}'
  params: {
    databaseAccount: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    databaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
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
    appiName: 'appi-${projectName}-${uniqueString(rgLandingZone.id)}'
    storageAccountName: 'sa${projectName}${uniqueString(rgLandingZone.id)}'
    cosmosDbAccountName: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    cosmosDbDatabaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZone.name
    
  ]
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
  ]
}



