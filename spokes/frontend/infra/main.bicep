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


// existing resources

resource rgLandingZone 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: rgLandingZoneName
}

var uniquePostFixForLandingzone = uniqueString(rgLandingZone.id)


resource functionApp 'Microsoft.Web/sites@2023-01-01' existing = {
  name: 'fn-${projectName}-api-${uniquePostFixForLandingzone}'
  scope: resourceGroup(rgLandingZoneName)
}

// end existing resources

module rg '../../../shared/infra/resource-group.bicep' = {
  name: 'resourceGroupModule-${buildNumber}'
  params: {
    resourceGroupName: rgName
    location: location
  }
}

var uniquePostFix = uniqueString(rg.outputs.id)

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
      WEBSITE_RUN_FROM_PACKAGE: 1
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccount.outputs.connectionString
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

module kvAccessPolicy '../../../shared/infra/keyvault-access-policies.bicep' = {
  name: 'KeyVaultAccessPolicy-${projectName}func-${buildNumber}'
  params: {
    keyvaultName: kvName
    permissions: [ 'get' ]
    tenantId: subscription().tenantId
    principalId: webApp.outputs.principalId
  }
  scope: resourceGroup(rgLandingZone.name)
  dependsOn: [
    webApp
  ]
}

