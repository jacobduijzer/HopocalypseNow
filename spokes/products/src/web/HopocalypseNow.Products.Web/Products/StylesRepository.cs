using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.Products.Web.Products;

public class StylesRepository(DatabaseContext databaseContext)
{
    public async Task<IEnumerable<Style>?> All() =>
        await databaseContext.Styles!.ToListAsync();
}