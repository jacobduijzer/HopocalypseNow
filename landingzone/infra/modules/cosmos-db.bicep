param projectName string
param location string
param uniquePostFix string

var accountName = 'cosmos-${projectName}-${uniquePostFix}'
var databaseName = 'db-${projectName}-${uniquePostFix}'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: toLower(accountName)
  location: location
  properties: {
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

output cosmosDbAccountName string = cosmosDbAccount.name
output cosmosDbName string = cosmosDbDatabase.name
output cosmosDbDatabaseName string = cosmosDbDatabase.name
