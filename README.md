# Hopocalypse Now: Brews for the End Times!

## Connect GitHub Actions to Azure

GitHub Actions need permissions to execute bicep or other commands in Azure. Create a connection by following the steps on this page: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure. Because you need permissions beyond resource groups, you need to make some changes so the Service Principle can make changes in your entire subscription.

Changes:

--scope /subscriptions/$subscriptionId


## Scenarios

Mongo vs CosmosDb

Sql Server vs CosmosDb
Sql Server vs Azure Sql Server (serverless)
Sql Server vs PostgreSql (serverless)

Worker vs Function

Rabbitmq vs Azure Service Bus

Elastic Search + logstash + Kibana vs App Insights

## Notes


### Create cosmos container

``` bicep
module storageAccount 'modules/storage-account.bicep' = {
  name: 'StorageAccount'
  params: {
    projectName: projectName
    location: location
  }
}

module serviceBus 'modules/serviceBus.bicep' = {
  name: 'ServiceBus'
  params: {
    projectName: projectName
    location: location
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'FunctionApp'
  params: { 
    projectName: projectName
    location: location
    applicationInsightsName: applicationInsights.outputs.appiName
    storageAccountName: storageAccount.outputs.name
    newOrdersTopicName: serviceBus.outputs.topicNewOrdersName
    newOrdersSubscriptionName: serviceBus.outputs.subscriptionNewOrdersName
    newOrdersListenRuleConnectionString: serviceBus.outputs.connectionStringNewOrdersListen
    newOrdersSendRuleConnectionString: serviceBus.outputs.connectionStringNewOrdersSend
    newPaymentsTopicName: serviceBus.outputs.topicNewPaymentName
    newPaymentsSubscriptionName: serviceBus.outputs.subscriptionNewPaymentName
    newPaymentsListenRuleConnectionString: serviceBus.outputs.connectionStringNewPaymentsListen
    newPaymentsSendRuleConnectionString: serviceBus.outputs.connectionStringNewPaymentsSend
  }
  dependsOn: [
    storageAccount
    serviceBus
  ]
}
```