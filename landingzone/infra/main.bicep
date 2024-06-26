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

module keyVault 'modules/keyvault.bicep' = {
  name: 'KeyVaultModule-${buildNumber}'
  params: {
    projectName: projectName
    uniquePostFix: uniquePostFix
  }
  scope: resourceGroup(rgName)
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'ApplicationInsightsModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    kvName: keyVault.outputs.kvName
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
    kvName: keyVault.outputs.kvName
  }
  scope: resourceGroup(rgName)
}

module serviceBus 'modules/service-bus.bicep' = {
  name: 'ServiceBusModule-${buildNumber}'
  params: {
    projectName: projectName
    location: location
    uniquePostFix: uniquePostFix
    kvName: keyVault.outputs.kvName
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
    kvName: keyVault.outputs.kvName
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
    scopeResourceGroup: rgName
    extraAppSettings: {
      AzureWebJobsStorage: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
      WEBSITE_SKIP_CONTENTSHARE_VALIDATION: 1
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${storageAccount.outputs.connectionStringName})'
      APPLICATIONINSIGHTS_CONNECTION_STRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${applicationInsights.outputs.secretConnectionStringName})'
      CosmosDbConnectionString: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${cosmosDb.outputs.secretConnectionStringName})'
      CosmosDbDatabaseName: cosmosDb.outputs.cosmosDbDatabaseName
      ServiceBusConnectionString: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.kvName};SecretName=${serviceBus.outputs.keyvaultFullConnectionStringSecretName})'
    }
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    keyVault
    applicationInsights
    appPlan
    cosmosDb
    serviceBus
    storageAccount
  ]
}

module kvAccessPolicy '../../shared/infra/keyvault-access-policies.bicep' = {
  name: 'KeyVaultAccessPolicy-${projectName}func-${buildNumber}'
  params: {
    keyvaultName: keyVault.outputs.kvName
    permissions: [ 'get' ]
    tenantId: subscription().tenantId
    principalId: functionApp.outputs.principalId
  }
  scope: resourceGroup(rgName)
  dependsOn: [
    keyVault
    functionApp
  ]
}
