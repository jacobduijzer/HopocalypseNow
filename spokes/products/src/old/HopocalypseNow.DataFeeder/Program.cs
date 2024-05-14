using HopocalypseNow.DataFeeder;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

IConfiguration configuration = new ConfigurationBuilder()
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true)
    .AddJsonFile("appsettings.local.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables()
    .AddCommandLine(args)
    .Build();

var connectionString = configuration.GetConnectionString("CosmosDbConnectionString") 
                       ?? throw new InvalidOperationException("CosmosDbConnectionString is missing");
var databaseName = configuration.GetValue<string>("CosmosDbDatabaseName")
                   ?? throw new InvalidOperationException("CosmosDbDatabaseName is missing");

var serviceCollection = new ServiceCollection()
    .AddDbContext<DatabaseContext>(options => options.UseCosmos(connectionString, databaseName))
    .AddTransient<BeerFeederService>()
    .AddSingleton<BeerDataFeeder>();

var container = serviceCollection.BuildServiceProvider();

var service = container.GetRequiredService<BeerFeederService>();

await service.CreateDatabaseAsync();
await service.FeedBeersAsync();
    