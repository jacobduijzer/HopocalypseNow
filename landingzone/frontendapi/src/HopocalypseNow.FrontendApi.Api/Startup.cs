using HopocalypseNow.Infrastructure;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

[assembly: FunctionsStartup(typeof(Startup))]

namespace HopocalypseNow.FrontendApi.Api;

public class Startup : FunctionsStartup
{
    public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
    {
        builder.ConfigurationBuilder
            .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables();
    }

    public override void Configure(IFunctionsHostBuilder builder)
    {
        var cosmosDbConnectionString = Environment.GetEnvironmentVariable("CosmosDbConnectionString") ??
                               throw new ArgumentNullException("Can't find variable 'CosmosDbConnectionString'.");
        
        var cosmosDbDatabaseName = Environment.GetEnvironmentVariable("CosmosDbDatabaseName") ??
                               throw new ArgumentNullException("Can't find variable 'CosmosDbDatabaseName'.");
        
        builder.Services
            .AddPooledDbContextFactory<DatabaseContext>(
                options => options.UseCosmos(cosmosDbConnectionString, cosmosDbDatabaseName));

        builder
            .AddGraphQLFunction()
            .RegisterDbContext<DatabaseContext>(DbContextKind.Synchronized)
            .AddQueryType<QueryType>();
    }
}
