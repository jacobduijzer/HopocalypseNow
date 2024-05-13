using HopocalypseNow.DataFeeder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

var serviceCollection = new ServiceCollection();
serviceCollection.AddDbContext<DatabaseContext>(
    options => options.UseCosmos(
        "AccountEndpoint=https://cosmos-hn-f4trzz3cw5dkg.documents.azure.com:443/;AccountKey=ecCTwSLv3QZ24aS9jC5bqgrrYjOmBxBZP16mJBTIPBviRdhlb6Rwqd5oeNutAjxd1kml6NbR3owBACDbUhJVig==;",
        "db-hn-f4trzz3cw5dkg"));
serviceCollection.AddTransient<BeerFeederService>()
    .AddSingleton<BeerDataFeeder>();

var container = serviceCollection.BuildServiceProvider();

var service = container.GetRequiredService<BeerFeederService>();

await service.CreateDatabaseAsync();
await service.FeedBeersAsync();
    