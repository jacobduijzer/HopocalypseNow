using HopocalypseNow.Orders.Processors.Domain;

namespace HopocalypseNow.Orders.Processors.Infrastructure;

public class OrderStorage : IOrderStorage
{
    private readonly DatabaseContext _databaseContext;

    public OrderStorage(DatabaseContext databaseContext) =>
        _databaseContext = databaseContext;

    public async Task Store(Order order)
    {
        await _databaseContext.Orders!.AddAsync(order);
        await _databaseContext.SaveChangesAsync();
    }
}