using HopocalypseNow.FrontendApi.Models;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class BeerType : ObjectType<Beer>
{
    protected override void Configure(IObjectTypeDescriptor<Beer> descriptor)
    {
        descriptor.BindFields(BindingBehavior.Implicit);
        
        descriptor
            .Field(f => f.Brewery)
            .Type<BreweryType>()
            .Resolve(async context =>
            {
                var factory = context.Service<IDbContextFactory<DatabaseContext>>();
                await using var dbContext = await factory.CreateDbContextAsync();
                return await dbContext.Breweries!.FirstOrDefaultAsync(x =>
                    x.BreweryId == context.Parent<Beer>().BreweryId);
            });
        
        descriptor
            .Field(f => f.Style)
            .Type<StyleType>()
            .Resolve(async context =>
            {
                var factory = context.Service<IDbContextFactory<DatabaseContext>>();
                await using var dbContext = await factory.CreateDbContextAsync();
                return await dbContext.Styles!.FirstOrDefaultAsync(x =>
                    x.StyleId == context.Parent<Beer>().StyleId);
            });
    }
}