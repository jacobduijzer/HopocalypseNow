using System.Text.Json;
using System.Threading.Tasks;
using HopocalypseNow.Orders.Processors.Domain;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace HopocalypseNow.Orders.Processors.FunctionApp;

public class OrderPlacedTrigger
{
    private readonly StoreOrderCommandHandler _storeOrderCommandHandler;
    private readonly ILogger<OrderPlacedTrigger> _logger;

    public OrderPlacedTrigger(
        StoreOrderCommandHandler storeOrderCommandHandler,
        ILogger<OrderPlacedTrigger> logger)
    {
        _storeOrderCommandHandler = storeOrderCommandHandler;
        _logger = logger;
    }
    
    [FunctionName("OrderPlacedTrigger")]
    public async Task RunAsync(
        [ServiceBusTrigger("topic-orders", "sub-topic-orders", Connection = "ServiceBusConnectionString")] string orderMessage,
        ILogger log)
    {
        log.LogInformation($"C# ServiceBus topic trigger function processed message: {orderMessage}");
        var order = JsonSerializer.Deserialize<RootObject>(orderMessage);
        await _storeOrderCommandHandler.Handle(new StoreOrderCommand(order.Order));
    }
}