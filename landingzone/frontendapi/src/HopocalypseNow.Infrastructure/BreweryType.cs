using HopocalypseNow.FrontendApi.Models;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.Infrastructure;

public class BreweryType : ObjectType<Brewery>
{
    protected override void Configure(IObjectTypeDescriptor<Brewery> descriptor)
    {
        descriptor.BindFields(BindingBehavior.Implicit);
        
        descriptor
            .Field(f => f.Beers)
            .Type<ListType<BeerType>>()
            .Resolve(async context =>
            {
                var factory = context.Service<IDbContextFactory<DatabaseContext>>();
                await using var dbContext = await factory.CreateDbContextAsync();
                return await dbContext.Beers!
                    .Where(x => x.BreweryId == context.Parent<Brewery>().BreweryId)
                    .ToListAsync();
            });
    }
}