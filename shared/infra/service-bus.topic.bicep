param projectName string
param applicationName string
param uniquePostFix string

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: 'sbns${projectName}${uniquePostFix}'
}

resource topic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: 'topic-${applicationName}'
  parent: serviceBusNamespace
  properties: {
    maxMessageSizeInKilobytes: 256
    defaultMessageTimeToLive: 'P14D'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    enableBatchedOperations: true
    supportOrdering: false
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    enablePartitioning: false
    enableExpress: false
  }
}

resource listenRule 'Microsoft.ServiceBus/namespaces/topics/AuthorizationRules@2022-10-01-preview' = {
  name: '${topic.name}-listen'
  parent: topic
  properties: {
    rights: [
      'Listen'
    ]
  }
}

resource sendRule 'Microsoft.ServiceBus/namespaces/topics/AuthorizationRules@2022-10-01-preview' = {
  name: '${topic.name}-send'
  parent: topic
  properties: {
    rights: [
      'Send'
    ]
  }
  dependsOn: [
    listenRule
  ]
}

resource subscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: 'sub-${topic.name}'
  parent: topic
  properties: {
    isClientAffine: false
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'P14D'
    deadLetteringOnMessageExpiration: false
    deadLetteringOnFilterEvaluationExceptions: false
    maxDeliveryCount: 10
    status: 'Active'
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P14D'
  }
}

output listenConnectionString string = listenRule.listKeys().primaryConnectionString
output sendConnectionString string = sendRule.listKeys().primaryConnectionString


// // Filter (belongs to a subscription)
// resource filter 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2022-10-01-preview' = {
//   name: 'filter-payment-requests'
//   parent: subscription
//   properties: {
//     action: {
//       compatibilityLevel: int
//       requiresPreprocessing: bool
//       sqlExpression: 'string'
//     }
//     correlationFilter: {
//       contentType: 'string'
//       correlationId: 'string'
//       label: 'string'
//       messageId: 'string'
//       properties: {}
//       replyTo: 'string'
//       replyToSessionId: 'string'
//       requiresPreprocessing: bool
//       sessionId: 'string'
//       to: 'string'
//     }
//     filterType: 'string'
//     sqlFilter: {
//       compatibilityLevel: int
//       requiresPreprocessing: bool
//       sqlExpression: 'string'
//     }
//   }
// }
