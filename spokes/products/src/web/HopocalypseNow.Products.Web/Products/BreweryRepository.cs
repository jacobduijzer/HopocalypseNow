using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.Products.Web.Products;

public class BreweryRepository(DatabaseContext databaseContext)
{
   public async Task<IEnumerable<Brewery>?> All() =>
       await databaseContext.Breweries!.ToListAsync();
}