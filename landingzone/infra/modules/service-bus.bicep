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
