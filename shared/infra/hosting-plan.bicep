param projectName string 
param location string
param uniquePostFix string

var hostingPlanName = 'plan-${projectName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

output hostingPlanId string = hostingPlan.id
