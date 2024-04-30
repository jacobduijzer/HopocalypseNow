param projectName string
param location string
param uniquePostFix string

var accountName = 'cosmos-${projectName}-${uniquePostFix}'
var databaseName = 'db-${projectName}-${uniquePostFix}'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: toLower(accountName)
  location: location
  properties: {
    enableFreeTier: true
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-11-15' = {
  parent: cosmosDbAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: 1000
    }
  }
}

// @description('The name for the SQL API container')
// param containerName string
// resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-11-15' = {
//   parent: database
//   name: containerName
//   properties: {
//     resource: {
//       id: containerName
//       partitionKey: {
//         paths: [
//           '/myPartitionKey'
//         ]
//         kind: 'Hash'
//       }
//       indexingPolicy: {
//         indexingMode: 'consistent'
//         includedPaths: [
//           {
//             path: '/*'
//           }
//         ]
//         excludedPaths: [
//           {
//             path: '/_etag/?'
//           }
//         ]
//       }
//     }
//   }
// }

// output location string = location
// output name string = container.name
// output resourceGroupName string = resourceGroup().name
// output resourceId string = container.id
