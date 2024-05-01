using HopocalypseNow.Models;

namespace HopocalypseNow.DataFeeder;

public class BeerFeederService
{
    private readonly BeerDataFeeder _beerDataFeeder;
    private DatabaseContext _databaseContext;
    public BeerFeederService(
        BeerDataFeeder beerDataFeeder,
        DatabaseContext databaseContext)
    {
        _beerDataFeeder = beerDataFeeder;
        _databaseContext = databaseContext ?? throw new ArgumentNullException(nameof(databaseContext));
    }

    public async Task CreateDatabaseAsync()
    {
        var created = await _databaseContext.Database.EnsureCreatedAsync();
        Console.WriteLine(created ? "database created" : "database already exists");
    }

    public async Task FeedBeersAsync()
    {
        var beers = _beerDataFeeder.GetRandomBeers(100);
        // _databaseContext.Beers?.Add(new Beer { BeerId = Guid.NewGuid(), Name = "Hopocalypse Now", Brewery = new Brewery { BreweryId = Guid.NewGuid(), Name = "Evil Twin Brewing" } });
        _databaseContext.Beers?.AddRange(beers);
        var changed = await _databaseContext.SaveChangesAsync();
        Console.WriteLine($"created {changed} records");
    }
}