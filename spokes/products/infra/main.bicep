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
  name: 'resource-groupModule'
  params: {
    resourceGroupName: rgName
    location: location
  }
}

// EXISTING RESOURCES

resource rgLandingZone 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: rgLandingZoneName
}

// resource appi 'Microsoft.Insights/components@2020-02-02' existing = {
//   name: 'appi-${projectName}-${uniqueString(rgLandingZone.id)}'
//   scope: resourceGroup(rgLandingZone.name)
// }


// collection, TODO: style / beer things
module cosmosDbDatabases '../../../shared/infra/cosmos-db.collection.bicep' = {
  name: 'CosmosDbDatabaseModule'
  params: {
    databaseAccount: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    databaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
    tableName: 'product'
    partitionKey: 'productId'
  }
  scope: resourceGroup(rgName)
}

// function
module functionApp '../../../shared/infra/function-app.bicep' = {
  name: 'FunctionAppModule'
  params: {
    projectName: projectName
    applicationName: 'api'
    location: location
    uniquePostFix: uniqueString(rg.outputs.id)
    hostingPlanName: 'plan-${projectName}-${uniqueString(rgLandingZone.id)}'
    appiName: 'appi-${projectName}-${uniqueString(rgLandingZone.id)}'
    storageAccountName: 'sa${projectName}${uniqueString(rgLandingZone.id)}'
    cosmosDbAccountName: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZone.name
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
  ]
}



