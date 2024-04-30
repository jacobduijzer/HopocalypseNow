# Hopocalypse Now: Brews for the End Times!

## Connect GitHub Actions to Azure

GitHub Actions need permissions to execute bicep or other commands in Azure. Create a connection by following the steps on this page: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure. Because you need permissions beyond resource groups, you need to make some changes so the Service Principle can make changes in your entire subscription.

Changes:

--scope /subscriptions/$subscriptionId
