using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.Products.Web.Products;

public class BeersRepository(DatabaseContext databaseContext)
{
    public async Task<IEnumerable<Beer>> All()
    {
        var beers = await databaseContext.Beers!.ToListAsync();
        var breweries = await databaseContext.Breweries!.ToListAsync();
        var styles = await databaseContext.Styles!.ToListAsync();

        foreach (var beer in beers)
        {
            beer.Brewery = breweries.FirstOrDefault(br => br.BreweryId == beer.BreweryId);
            beer.Style = styles.FirstOrDefault(s => s.StyleId == beer.StyleId);
        }

        return beers;
    }
}