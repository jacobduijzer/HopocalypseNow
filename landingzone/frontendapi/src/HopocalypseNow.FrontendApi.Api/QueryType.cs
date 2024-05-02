using HopocalypseNow.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Api;

public class QueryType : ObjectType<Query>
{
    protected override void Configure(IObjectTypeDescriptor<Query> descriptor)
    {
        descriptor.Name(OperationTypeNames.Query);

        descriptor
            .Field("beers")
            .Type<ListType<BeerType>>()
            .Resolve(async context =>
            {
                var factory = context.Service<IDbContextFactory<DatabaseContext>>();
                await using var dbContext = await factory.CreateDbContextAsync();
                return await dbContext.Beers!.ToListAsync();
            });
        
        descriptor
            .Field("breweries")
            .Type<ListType<BreweryType>>()
            .Resolve(async context =>
            {
                var factory = context.Service<IDbContextFactory<DatabaseContext>>();
                await using var dbContext = await factory.CreateDbContextAsync();
                return await dbContext.Breweries!.ToListAsync();
            });

        descriptor
            .Field("styles")
            .Type<ListType<StyleType>>()
            .Resolve(async context =>
            {
                var factory = context.Service<IDbContextFactory<DatabaseContext>>();
                await using var dbContext = await factory.CreateDbContextAsync();
                return await dbContext.Styles!.ToListAsync();
            });
    }
}