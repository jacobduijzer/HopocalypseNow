param projectName string
param applicationName string
param location string
param uniquePostFix string
param hostingPlanName string
param scopeResourceGroup string
param storageAccountName string

param extraAppSettings object = {
   PlaceholderSetting: ''
}

var functionAppName = 'fn-${projectName}-${applicationName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: hostingPlanName
  scope: resourceGroup(scopeResourceGroup)
}

var basicAppSettings = {
  WEBSITE_CONTENTSHARE: toLower(functionAppName)
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
}

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
      linuxFxVersion: 'DOTNET|8.0'
      alwaysOn: false
    }
    httpsOnly: true
  }
}

module appSettings 'app-settings.bicep' = {
  name: '${functionAppName}-appsettings'
  params: {
    webAppName: functionApp.name
    currentAppSettings: basicAppSettings
    extraAppSettings: extraAppSettings
  }
}


// storage account permissions

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

var storageBlobDataContributorRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

resource storageFunctionAppPermissions 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storageAccount.name, functionApp.name, storageBlobDataContributorRole)
  scope: storageAccount
  properties: {
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: storageBlobDataContributorRole
  }
}

output funcName string = functionApp.name
output defaultHostName string = functionApp.properties.defaultHostName
output principalId string = functionApp.identity.principalId
