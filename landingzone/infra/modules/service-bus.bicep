param projectName string
param location string
param uniquePostFix string
param kvName string

var serviceBusNamespaceName = 'sbns${projectName}${uniquePostFix}'

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource authorizationRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-10-01-preview' = {
  name: 'auth-${projectName}'
  parent: serviceBusNamespace
  properties: {
    rights: [
      'Listen'
      'Manage'
      'Send'
    ]
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
}

resource fullSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'servicebus-full-connection-string'
  properties: {
    value: authorizationRule.listKeys().primaryConnectionString
  }
}

output keyvaultFullConnectionStringSecretName string = fullSecret.name
