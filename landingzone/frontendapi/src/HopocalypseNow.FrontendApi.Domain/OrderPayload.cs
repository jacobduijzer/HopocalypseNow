namespace HopocalypseNow.FrontendApi.Models;

public class OrderPayload
{
    public List<OrderItemPayload> OrderItems { get; set; } = new ();
}

public class OrderItemPayload
{
    public Guid BeerId { get; set; }
    public int Amount { get; set; }
}