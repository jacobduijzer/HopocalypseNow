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
    appiName: 'appi-${projectName}-${uniqueString(rgLandingZone.id)}'
    cosmosDbAccountName: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    cosmosDbDatabaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZone.name
    extraAppSettings: [{
      name: 'FrontendApiAddress'
      value: '${functionApp.properties.defaultHostName}/api/graphql'
    }]
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
  ]
}
