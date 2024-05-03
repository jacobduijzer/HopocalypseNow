namespace HopocalypseNow.FrontendApi.Models;

public record ConvertToOrderCommand(OrderPayload OrderPayload);

public class ConvertToOrderCommandHandler
{
    public Order Handle(ConvertToOrderCommand convertToOrderCommand)
    {
        var order = new Order { OrderStatus = OrderStatus.Placed };
        
        foreach(var orderItemPayload in convertToOrderCommand.OrderPayload.OrderItems)
        {
            order.OrderItems.Add(new OrderItem
            {
                BeerId = orderItemPayload.BeerId,
                Amount = orderItemPayload.Amount
            });
        }
        
        return order;
    }
}