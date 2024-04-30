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
    name: rgName
    location: location
  }
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'ApplicationInsights'
  params: {
    projectName: projectName
    location: location
  }
  scope: resourceGroup(rgName)
}

module cosmosDb 'modules/cosmos-db.bicep' = {
  name: 'CosmosDb'
  params: {
    projectName: projectName
    location: dbLocation
  }
  scope: resourceGroup(rgName)
}
