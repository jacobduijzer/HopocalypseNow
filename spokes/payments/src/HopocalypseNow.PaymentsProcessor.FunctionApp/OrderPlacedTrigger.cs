using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace HopocalypseNow.PaymentsProcessor.FunctionApp;

public  class OrderPlacedTrigger
{
    private readonly ServiceBusClient _serviceBusClient;

    public OrderPlacedTrigger(ServiceBusClient serviceBusClient)
    {
        _serviceBusClient = serviceBusClient;
    }

    [FunctionName("OrderPlacedTrigger")]
    public async Task RunAsync([CosmosDBTrigger(
            databaseName: "%CosmosDbDatabaseName%",
            containerName: "order",
            Connection = "CosmosDbConnectionString",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)]
        IReadOnlyList<Order> input,
        ILogger log)
    {
        var sender = _serviceBusClient.CreateSender("topic-payments");
        
        log.LogInformation("New orders received: " + input.Count);
        foreach (var order in input)
        {
            log.LogInformation("Order received: " + order.OrderId);
            var paymentRequestedPayload = new PaymentRequestedPayload
            {
                Order = order
            };
            var payload = JsonSerializer.Serialize(paymentRequestedPayload);
            await sender.SendMessageAsync(new ServiceBusMessage(payload));
        }
        log.LogInformation("Done processing orders.");
    }
}