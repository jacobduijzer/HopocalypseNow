using System;

namespace HopocalypseNow.PaymentsProcessor.FunctionApp;

public class PaymentRequestedPayload
{
    public Guid PaymentId { get; set; } = Guid.NewGuid();
    
    public Order Order { get; set; }
    
    public DateTime Created { get; set; } = DateTime.Now;
}