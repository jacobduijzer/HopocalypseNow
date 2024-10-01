using Azure.Monitor.OpenTelemetry.AspNetCore;
using Azure.Monitor.OpenTelemetry.Exporter;
using HopocalypseNow.Products.Web.Components;
using HopocalypseNow.Products.Web.Products;
using Microsoft.AspNetCore.Hosting.Builder;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetValue<string>("CosmosDbConnectionString") 
                       ?? throw new InvalidOperationException("CosmosDbConnectionString is missing");

var databaseName = builder.Configuration.GetValue<string>("CosmosDbDatabaseName")
                   ?? throw new InvalidOperationException("CosmosDbDatabaseName is missing");

var appInsightsConnectionString = builder.Configuration.GetValue<string>("APPLICATIONINSIGHTS_CONNECTION_STRING")
                                 ?? throw new InvalidOperationException("ApplicationInsightsConnectionString is missing");

builder.Services
    .AddDbContext<DatabaseContext>(options => options.UseCosmos(connectionString, databaseName))
    .AddScoped<BreweryRepository>()
    .AddScoped<StylesRepository>()
    .AddScoped<BeersRepository>()
    .AddScoped<BeerFeederService>()
    .AddScoped<BeerDataFeeder>()
    .AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddHealthChecks();


builder.Services
    .AddOpenTelemetry()
    .UseAzureMonitor()
    .WithTracing();

builder.Logging.AddOpenTelemetry(options =>
{
    options.AddAzureMonitorLogExporter(settings => settings.ConnectionString = appInsightsConnectionString);
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.MapHealthChecks("/healthz");

app.Run();