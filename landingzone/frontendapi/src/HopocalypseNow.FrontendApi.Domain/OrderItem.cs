namespace HopocalypseNow.FrontendApi.Models;

public class OrderItem
{
   public Guid OrderItemId { get; set; } = Guid.NewGuid();
   public Guid BeerId { get; set; }
   public int Amount { get; set; }
}
