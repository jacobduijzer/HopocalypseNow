using HopocalypseNow.Products.Web.Components;
using HopocalypseNow.Products.Web.Products;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetValue<string>("CosmosDbConnectionString") 
                       ?? throw new InvalidOperationException("CosmosDbConnectionString is missing");

var databaseName = builder.Configuration.GetValue<string>("CosmosDbDatabaseName")
                   ?? throw new InvalidOperationException("CosmosDbDatabaseName is missing");

builder.Services.AddDbContext<DatabaseContext>(options => options.UseCosmos(connectionString, databaseName))
    .AddTransient<BeerFeederService>()
    .AddSingleton<BeerDataFeeder>()
    .AddRazorComponents()
    .AddInteractiveServerComponents();

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

app.Run();