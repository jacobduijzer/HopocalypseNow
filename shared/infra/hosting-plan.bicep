param projectName string 
param location string
param uniquePostFix string

var hostingPlanName = 'plan-${projectName}-${uniquePostFix}'

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  kind: 'linux'
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  properties: {}
}

output hostingPlanName string = hostingPlan.name
