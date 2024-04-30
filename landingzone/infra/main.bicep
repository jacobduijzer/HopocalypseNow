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
  name: 'resource-groupModule'
  params: {
    resourceGroupName: rgName
    location: location
  }
}

var uniquePostFix = uniqueString(rg.outputs.id)

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'ApplicationInsights'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: 'CosmosDb'
  params: {
    projectName: projectName
    location: dbLocation
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module appPlan '../../shared/infra/hosting-plan.bicep' = {
  name: 'AppPlan'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module functionApp '../../shared/infra/function-app.bicep' = {
  name: 'FunctionApp'
  params: {
    projectName: projectName
    applicationName: 'api'
    location: location
    uniquePostFix: uniquePostFix
    hostingPlanId: appPlan.outputs.hostingPlanId
    appiName: applicationInsights.outputs.appiName
    cosmosDbAccountName: cosmosDb.outputs.cosmosDbAccountName
  }
  scope: resourceGroup(rgName)
}
