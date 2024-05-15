namespace HopocalypseNow.Orders.Processors.Domain;

public class RootObject
{
    public Order Order { get; set; }
}

public class Order
{
    public string OrderId { get; set; }
    public int OrderStatus { get; set; }
    public ICollection<OrderItems> OrderItems { get; set; }
    public string Created { get; set; }
}

public class OrderItems
{
    public string OrderItemId { get; set; }
    public string BeerId { get; set; }
    public int Amount { get; set; }
}

