param projectName string
param uniquePostFix string

var kvName = 'kv-${projectName}-${uniquePostFix}'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: kvName
  location: resourceGroup().location
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true  
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    accessPolicies: [
      {
        objectId: '2aa0442f-8cac-4064-845b-257c44175cf7'
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'all'
          ]
        }
      }
      {
        objectId: 'f960d6cf-408f-45ac-85da-8ff10e90d1d1'
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'all'
            'list'
          ]
          certificates: [
            'get'
            'create'
          ]
          keys: [
            'encrypt'
            'decrypt'
          ]
        }
      }
    ]
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output kvName string = kvName
