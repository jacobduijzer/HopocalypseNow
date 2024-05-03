using System;
using HopocalypseNow.PaymentsProcessor.FunctionApp;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Azure;

[assembly: FunctionsStartup(typeof(Startup))]

namespace HopocalypseNow.PaymentsProcessor.FunctionApp;

public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        var cosmosDbConnectionString = Environment.GetEnvironmentVariable("CosmosDbConnectionString") ??
                                       throw new ArgumentNullException("Can't find variable 'CosmosDbConnectionString'.");
        
        var cosmosDbDatabaseName = Environment.GetEnvironmentVariable("CosmosDbDatabaseName") ??
                                   throw new ArgumentNullException("Can't find variable 'CosmosDbDatabaseName'.");
        
        var serviceBusConnectionString =Environment.GetEnvironmentVariable("ServiceBusConnectionString") ??
                                        throw new ArgumentNullException("Can't find variable 'ServiceBusConnectionString'."); 
        
        builder.Services.AddAzureClients(clientBuilder =>
        {
            clientBuilder.AddServiceBusClient(serviceBusConnectionString);
        });
    }
}