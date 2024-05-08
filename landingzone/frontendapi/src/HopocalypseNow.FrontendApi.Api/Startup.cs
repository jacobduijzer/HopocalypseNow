using HopocalypseNow.FrontendApi.Infrastructure;
using HopocalypseNow.FrontendApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Azure;

[assembly: FunctionsStartup(typeof(Startup))]

namespace HopocalypseNow.FrontendApi.Api;

public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        var cosmosDbConnectionString = Environment.GetEnvironmentVariable("CosmosDbConnectionString") ??
                               throw new ArgumentNullException("Can't find variable 'CosmosDbConnectionString'.");
        
        var cosmosDbDatabaseName = Environment.GetEnvironmentVariable("CosmosDbDatabaseName") ??
                               throw new ArgumentNullException("Can't find variable 'CosmosDbDatabaseName'.");
        
        var serviceBusConnectionString = Environment.GetEnvironmentVariable("ServiceBusConnectionString") ??
                                        throw new ArgumentNullException("Can't find variable 'ServiceBusConnectionString'."); 

      
        
        builder.Services
            .AddPooledDbContextFactory<DatabaseContext>(
                options => options.UseCosmos(cosmosDbConnectionString, cosmosDbDatabaseName));

        builder
            .AddGraphQLFunction()
            .RegisterDbContext<DatabaseContext>(DbContextKind.Synchronized)
            .AddQueryType<QueryType>()
            .AddMutationType<MutationType>();

        builder.Services.AddScoped<ConvertToOrderCommandHandler>()
            .AddScoped<IRepository<Beer>, BaseRepository<Beer>>();
        
        builder.Services.AddAzureClients(clientBuilder =>
            clientBuilder.AddServiceBusClient(serviceBusConnectionString)); 
    }
}
