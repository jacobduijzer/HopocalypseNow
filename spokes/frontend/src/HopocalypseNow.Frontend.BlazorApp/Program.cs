var builder = WebApplication.CreateBuilder(args);

var frontendApiAddress = builder.Configuration.GetValue<string>( "FrontendApiAddress") ?? 
                         throw new ArgumentNullException("Can't find variable 'FrontendApiAddress'."); 

builder.Services
    .AddHopocalypseNowClient()
    .ConfigureHttpClient(sp => sp.BaseAddress = new Uri(frontendApiAddress));

builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");
app.Run();