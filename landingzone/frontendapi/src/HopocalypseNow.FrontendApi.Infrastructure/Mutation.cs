using HopocalypseNow.FrontendApi.Models;
using Microsoft.EntityFrameworkCore;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class Mutation
{
    private readonly ConvertToOrderCommandHandler _convertToOrderCommandHandler;
    private readonly IDbContextFactory<DatabaseContext> _dbContextFactory;

    public Mutation(
        ConvertToOrderCommandHandler convertToOrderCommandHandler,
        IDbContextFactory<DatabaseContext> dbContextFactory)
    {
        _convertToOrderCommandHandler = convertToOrderCommandHandler;
        _dbContextFactory = dbContextFactory;
    }

    public async Task<OrderAddedPayload> AddOrder(OrderPayload input)
    {
        Order order = _convertToOrderCommandHandler.Handle(new ConvertToOrderCommand(input));
        
        await using var dbContext = await _dbContextFactory.CreateDbContextAsync();
        await dbContext.Orders!.AddAsync(order);
        await dbContext.SaveChangesAsync();
        return new OrderAddedPayload(order);
    } 
}