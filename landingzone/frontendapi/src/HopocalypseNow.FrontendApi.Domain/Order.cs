namespace HopocalypseNow.FrontendApi.Models;

public class Order
{
    public Guid OrderId { get; set; } = Guid.NewGuid();
    public OrderStatus OrderStatus { get; set; }
    public List<OrderItem> OrderItems { get; set; } = new(); 
    public DateTime Created { get; set; } = DateTime.Now;
}

public enum OrderStatus
{
    Placed,
    Completed
}