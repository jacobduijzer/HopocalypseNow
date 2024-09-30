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



// existing resources

resource rgLandingZone 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: rgLandingZoneName
}

var uniquePostFixForLandingzone = uniqueString(rgLandingZone.id)
var kvName = 'kv-${projectName}-${uniquePostFixForLandingzone}'

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

module serviceBusTopic '../../../shared/infra/service-bus.topic.bicep' = {
  name: 'ServiceBusTopic-${buildNumber}'
  params: {
    projectName: projectName
    uniquePostFix: uniquePostFixForLandingzone
    applicationName: 'payments'
  }
  scope: rgLandingZone
}

var databaseName = 'db-${projectName}-${uniquePostFixForLandingzone}'

module functionApp '../../../shared/infra/function-app.bicep' = {
  name: 'FunctionAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: 'payments'
    location: location
    uniquePostFix: uniquePostFix
    hostingPlanName: 'plan-${projectName}-${uniquePostFixForLandingzone}'
    scopeResourceGroup: rgLandingZoneName
    extraAppSettings: {
      //AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
      // TEMP WORKAROUND, ISSUE WITH FUNCTION APP DEPLOYMENT
      AzureWebJobsStorage: storageAccount.outputs.connectionString
      WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
      //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
      // TEMP WORKAROUND, ISSUE WITH FUNCTION APP DEPLOYMENT
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: storageAccount.outputs.connectionString
      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=appi-connection-string)'
      CosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=cosmosdb-connection-string)'
      CosmosDbDatabaseName: databaseName
      ServiceBusConnectionString: '@Microsoft.KeyVault(VaultName=${kvName};SecretName=sbns-full-connection-string)'
    }
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    storageAccount
    rg
  ]
}



