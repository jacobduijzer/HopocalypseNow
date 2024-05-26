param projectName string
param location string
param uniquePostFix string
param kvName string

var accountName = 'cosmos-${projectName}-${uniquePostFix}'
var databaseName = 'db-${projectName}-${uniquePostFix}'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
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

resource cosmosDbDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
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

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'cosmosdb-connection-string'
  properties: {
    value: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

output cosmosDbAccountName string = cosmosDbAccount.name
output cosmosDbName string = cosmosDbDatabase.name
output cosmosDbDatabaseName string = cosmosDbDatabase.name
output secretConnectionStringName string = secret.name
