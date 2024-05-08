param projectName string
param location string
param uniquePostFix string

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

output serviceBusConnectionString string = authorizationRule.listKeys().primaryConnectionString
