using HopocalypseNow.FrontendApi.Models;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class StyleType : ObjectType<Style>
{
    protected override void Configure(IObjectTypeDescriptor<Style> descriptor)
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
                    .Where(x => x.StyleId == context.Parent<Style>().StyleId)
                    .ToListAsync();
            });
    } 
}