param name string 
param location string

param tags object = {
  environment: 'dta'
  maintainer: 'kraken'
}

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: name
  location: location
  tags: tags
}

output id string = rg.id
