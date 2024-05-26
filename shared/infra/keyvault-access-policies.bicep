param keyvaultName string
param tenantId string
param principalId string
param permissions string[]

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyvaultName
}

resource accessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2023-07-01' = {
  name: 'replace'
  parent: kv
  properties: {
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
        permissions: {
          secrets: permissions
        }
      }
    ]
  }
}
