param buildNumber string

@minLength(2)
@maxLength(8)
@description('Provide a project name for the naming of all resources')
param projectName string 

@description('Provide a location for the resources.')
param location string = 'westeurope'

targetScope = 'subscription'

var rgName = 'rg-${projectName}-payments'
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

module serviceBusTopic '../../../shared/infra/service-bus.topic.bicep' = {
  name: 'ServiceBusTopic-${buildNumber}'
  params: {
    projectName: projectName
    uniquePostFix: uniqueString(rgLandingZone.id)
  }
  scope: rgLandingZone
}

module functionApp '../../../shared/infra/function-app.bicep' = {
  name: 'FunctionAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: 'payments'
    location: location
    uniquePostFix: uniqueString(rg.outputs.id)
    hostingPlanName: 'plan-${projectName}-${uniqueString(rgLandingZone.id)}'
    appiName: 'appi-${projectName}-${uniqueString(rgLandingZone.id)}'
    storageAccountName: 'sa${projectName}${uniqueString(rgLandingZone.id)}'
    cosmosDbAccountName: 'cosmos-${projectName}-${uniqueString(rgLandingZone.id)}'
    cosmosDbDatabaseName: 'db-${projectName}-${uniqueString(rgLandingZone.id)}'
    scopeResourceGroup: rgLandingZone.name
    extraAppSettings: [{
      name: 'ServiceBusConnectionString'
      value: serviceBusTopic.outputs.sendConnectionString
    }]
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
    serviceBusTopic
  ]
}



