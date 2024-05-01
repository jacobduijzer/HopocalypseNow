[assembly: FunctionsStartup(typeof(Startup))]

namespace HopocalypseNow.FrontendApi.Api;

public class Startup : FunctionsStartup
{
    public override void Configure(IFunctionsHostBuilder builder)
    {
        builder
            .AddGraphQLFunction()
            .AddQueryType<Query>();
    }
}