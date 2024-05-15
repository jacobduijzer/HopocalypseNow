using System;
using HopocalypseNow.Orders.Processors.Domain;
using HopocalypseNow.Orders.Processors.FunctionApp;
using HopocalypseNow.Orders.Processors.Infrastructure;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Azure;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(Startup))]
namespace HopocalypseNow.Orders.Processors.FunctionApp;


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

        builder.Services
            .AddDbContext<DatabaseContext>(options
                => options.UseCosmos(cosmosDbConnectionString, cosmosDbDatabaseName))
            .AddAzureClients(clientBuilder
                => clientBuilder.AddServiceBusClient(serviceBusConnectionString));

        builder.Services
            .AddScoped<IOrderStorage, OrderStorage>()
            .AddScoped<StoreOrderCommandHandler>();
    }
}