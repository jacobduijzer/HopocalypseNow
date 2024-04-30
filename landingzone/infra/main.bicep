@minLength(2)
@maxLength(8)
@description('Provide a project name for the naming of all resources')
param projectName string 

@description('Provide a location for the resources.')
param location string = 'westeurope'

targetScope = 'subscription'

var rgName = 'rg-${projectName}-landingzone'

module rg '../../shared/infra/resource-group.bicep' = {
  name: 'resource-groupModule'
  params: {
    name: rgName
    location: location
  }
}

module applicationInsights 'modules/application-insights.bicep' = {
  name: 'ApplicationInsights'
  params: {
    projectName: projectName
    location: location
  }
  scope: resourceGroup(rgName)
}

// module storageAccount 'modules/storage-account.bicep' = {
//   name: 'StorageAccount'
//   params: {
//     projectName: projectName
//     location: location
//   }
// }

// module serviceBus 'modules/serviceBus.bicep' = {
//   name: 'ServiceBus'
//   params: {
//     projectName: projectName
//     location: location
//   }
// }

// module functionApp 'modules/functionApp.bicep' = {
//   name: 'FunctionApp'
//   params: { 
//     projectName: projectName
//     location: location
//     applicationInsightsName: applicationInsights.outputs.appiName
//     storageAccountName: storageAccount.outputs.name
//     newOrdersTopicName: serviceBus.outputs.topicNewOrdersName
//     newOrdersSubscriptionName: serviceBus.outputs.subscriptionNewOrdersName
//     newOrdersListenRuleConnectionString: serviceBus.outputs.connectionStringNewOrdersListen
//     newOrdersSendRuleConnectionString: serviceBus.outputs.connectionStringNewOrdersSend
//     newPaymentsTopicName: serviceBus.outputs.topicNewPaymentName
//     newPaymentsSubscriptionName: serviceBus.outputs.subscriptionNewPaymentName
//     newPaymentsListenRuleConnectionString: serviceBus.outputs.connectionStringNewPaymentsListen
//     newPaymentsSendRuleConnectionString: serviceBus.outputs.connectionStringNewPaymentsSend
//   }
//   dependsOn: [
//     storageAccount
//     serviceBus
//   ]
// }
