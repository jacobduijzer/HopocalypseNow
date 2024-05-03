using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace HopocalypseNow.PaymentsProcessor.FunctionApp;

public static class OrderPlacedTrigger
{
    [FunctionName("OrderPlacedTrigger")]
    public static async Task RunAsync([CosmosDBTrigger(
            databaseName: "%CosmosDbDatabaseName%",
            containerName: "order",
            Connection = "CosmosDbConnectionString",
            LeaseContainerName = "leases",
            CreateLeaseContainerIfNotExists = true)]
        IReadOnlyList<Order> input,
        ILogger log)
    {
        log.LogInformation("New orders received: " + input.Count);
        foreach (var order in input)
        {
            log.LogInformation("Order received: " + order.OrderId);
        }
        log.LogInformation("Done processing orders.");
    }
}