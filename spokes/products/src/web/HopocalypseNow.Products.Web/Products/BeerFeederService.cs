namespace HopocalypseNow.Products.Web.Products;

public class BeerFeederService(
    BreweryRepository breweries,
    StylesRepository styles,
    BeersRepository beers,
    BeerDataFeeder beerDataFeeder,
    DatabaseContext databaseContext)
{
    
    private readonly DatabaseContext _databaseContext =
        databaseContext ?? throw new ArgumentNullException(nameof(databaseContext));

    public async Task CreateDatabaseAsync()
    {
        var created = await _databaseContext.Database.EnsureCreatedAsync();
        Console.WriteLine(created ? "database created" : "database already exists");
    }

    public async Task FeedBeersAsync(int numberOfBeers)
    {
        var allBreweries = await breweries.All();
        if(allBreweries == null || !allBreweries.Any())
        {
            allBreweries = beerDataFeeder.Breweries;
        }
        
        var allStyles = await styles.All();
        if(allStyles == null || !allStyles.Any())
        {
            allStyles = beerDataFeeder.Styles;
        }
        
        var beers = beerDataFeeder.GetRandomBeers(numberOfBeers, allBreweries.ToList(), allStyles.ToList());
        
        _databaseContext.Beers?.AddRange(beers);
        var changed = await _databaseContext.SaveChangesAsync();
        Console.WriteLine($"created {changed} records");
    }
}