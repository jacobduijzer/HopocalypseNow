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

var beer = { name: 'beers', partitionKey: 'beerId'}
var breweries = { name: 'breweries', partitionKey: 'breweryId' }
var styles = { name: 'styles', partitionKey: 'styleId' }

var collections = [beer, breweries, styles]
var databaseName = 'db-${projectName}-${uniquePostFixForLandingzone}'

module cosmosDbDatabases '../../../shared/infra/cosmos-db.collection.bicep' = [for collection in collections: {
  name: 'CosmosDbDatabaseModule-${collection.name}-${buildNumber}'
  params: {
    databaseAccount: 'cosmos-${projectName}-${uniquePostFixForLandingzone}'
    databaseName: databaseName
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

module kvAccessPolicyForFunc '../../../shared/infra/keyvault-access-policies.bicep' = {
  name: 'KeyVaultAccessPolicy-${projectName}func-${buildNumber}'
  params: {
    keyvaultName: kvName
    permissions: [ 'get' ]
    tenantId: subscription().tenantId
    principalId: functionApp.outputs.principalId
  }
  scope: resourceGroup(rgLandingZoneName)
  dependsOn: [
    functionApp
  ]
}

module webapp '../../../shared/infra/web-app.bicep' = {
  name: 'WebAppModule-${buildNumber}'
  params: {
    projectName: projectName
    applicationName: 'web'
    location: location
    uniquePostFix: uniqueString(rg.outputs.id)
    hostingPlanName: 'plan-${projectName}-${uniquePostFixForLandingzone}'
    scopeResourceGroup: rgLandingZoneName
    extraAppSettings: {
      WEBSITE_RUN_FROM_PACKAGE: 1
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

module kvAccessPolicyForWeb '../../../shared/infra/keyvault-access-policies.bicep' = {
  name: 'KeyVaultAccessPolicy-${projectName}web-${buildNumber}'
  params: {
    keyvaultName: kvName
    permissions: [ 'get' ]
    tenantId: subscription().tenantId
    principalId: webapp.outputs.principalId
  }
  scope: resourceGroup(rgLandingZoneName)
  dependsOn: [
    functionApp
  ]
}

