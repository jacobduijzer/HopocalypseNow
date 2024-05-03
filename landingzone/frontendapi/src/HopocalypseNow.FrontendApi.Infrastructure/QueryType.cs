using HotChocolate.Resolvers;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class QueryType : ObjectType
{
    protected override void Configure(IObjectTypeDescriptor descriptor)
    {
        descriptor.Name(OperationTypeNames.Query);

        descriptor
            .Field("beers")
            .Type<ListType<BeerType>>()
            .Resolve(async context =>
            {
                await using var dbContext = await GetContext(context); 
                return await dbContext.Beers!.ToListAsync();
            });
        
        descriptor
            .Field("breweries")
            .Type<ListType<BreweryType>>()
            .Resolve(async context =>
            {
                await using var dbContext = await GetContext(context); 
                return await dbContext.Breweries!.ToListAsync();
            });

        descriptor
            .Field("styles")
            .Type<ListType<StyleType>>()
            .Resolve(async context =>
            {
                await using var dbContext = await GetContext(context); 
                return await dbContext.Styles!.ToListAsync();
            });

        descriptor
            .Field("orders")
            .Type<ListType<OrderType>>()
            .Resolve(async context =>
            {
                await using var dbContext = await GetContext(context);
                return await dbContext.Orders!.ToListAsync();
            });

        descriptor
            .Field("order")
            .Type<OrderType>()
            .Argument("orderId", a => a.Type<NonNullType<IdType>>())
            .Resolve(async context =>
            {
                var orderId = Guid.Parse(context.ArgumentValue<string>("orderId"));
                await using var dbContext = await GetContext(context);
                return await dbContext.Orders!.FirstOrDefaultAsync(o => o.OrderId == orderId);
            });
    }
    
    private async Task<DatabaseContext> GetContext(IResolverContext context)
    {
        var factory = context.Service<IDbContextFactory<DatabaseContext>>();
        return await factory.CreateDbContextAsync();
    }
}