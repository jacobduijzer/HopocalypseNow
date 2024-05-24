param projectName string
param uniquePostFix string

var kvName = 'kv${projectName}${uniquePostFix}'

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
    // accessPolicies: [
    //   {
    //     objectId: objectId
    //     tenantId: tenantId
    //     permissions: {
    //       keys: keysPermissions
    //       secrets: secretsPermissions
    //     }
    //   }
    // ]
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
