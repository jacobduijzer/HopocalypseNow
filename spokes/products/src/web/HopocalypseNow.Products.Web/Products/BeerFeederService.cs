namespace HopocalypseNow.Products.Web.Products;

public class BeerFeederService(
    BeerDataFeeder beerDataFeeder,
    DatabaseContext databaseContext)
{
    private DatabaseContext _databaseContext = databaseContext ?? throw new ArgumentNullException(nameof(databaseContext));

    public async Task CreateDatabaseAsync()
    {
        var created = await _databaseContext.Database.EnsureCreatedAsync();
        Console.WriteLine(created ? "database created" : "database already exists");
    }

    public async Task FeedBeersAsync(int numberOfBeers)
    {
        var beers = beerDataFeeder.GetRandomBeers(numberOfBeers);
        _databaseContext.Beers?.AddRange(beers);
        var changed = await _databaseContext.SaveChangesAsync();
        Console.WriteLine($"created {changed} records");
    }
}