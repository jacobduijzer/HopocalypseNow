using System;

namespace HopocalypseNow.PaymentsProcessor.FunctionApp;

public class OrderItem
{
    public Guid OrderItemId { get; set; } = Guid.NewGuid();
    public Guid BeerId { get; set; }
    public int Amount { get; set; }
}
