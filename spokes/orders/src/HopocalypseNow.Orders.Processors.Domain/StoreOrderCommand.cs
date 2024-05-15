namespace HopocalypseNow.Orders.Processors.Domain;

public record StoreOrderCommand(Order Order);

public class StoreOrderCommandHandler
{
    private readonly IOrderStorage _orderStorage;

    public StoreOrderCommandHandler(IOrderStorage orderStorage) =>
        _orderStorage = orderStorage;

    public async Task Handle(StoreOrderCommand storeOrderCommand) =>
        await _orderStorage.Store(storeOrderCommand.Order);
}