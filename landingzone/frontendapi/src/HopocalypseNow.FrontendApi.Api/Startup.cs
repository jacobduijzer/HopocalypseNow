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
        builder.Services
            .AddPooledDbContextFactory<DatabaseContext>(
                options => options.UseCosmos(
                    "TODO",
                    "TODO"));

        builder
            .AddGraphQLFunction()
            .RegisterDbContext<DatabaseContext>(DbContextKind.Synchronized)
            .AddQueryType<QueryType>();
    }
}