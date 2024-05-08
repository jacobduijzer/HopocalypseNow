using System.Text.Json;
using Azure.Messaging.ServiceBus;
using HopocalypseNow.FrontendApi.Models;

namespace HopocalypseNow.FrontendApi.Infrastructure;

public class Mutation
{
    private readonly ConvertToOrderCommandHandler _convertToOrderCommandHandler;
    private readonly ServiceBusClient _serviceBusClient;

    public Mutation(
        ConvertToOrderCommandHandler convertToOrderCommandHandler,
        ServiceBusClient serviceBusClient)
    {
        _convertToOrderCommandHandler = convertToOrderCommandHandler;
        _serviceBusClient = serviceBusClient;
    }

    public async Task<OrderAddedPayload> AddOrder(OrderPayload input)
    {
        var order = _convertToOrderCommandHandler.Handle(new ConvertToOrderCommand(input));
        
        var sender = _serviceBusClient.CreateSender("topic-orders");
        var payload = JsonSerializer.Serialize(new OrderAddedPayload(order));
        await sender.SendMessageAsync(new ServiceBusMessage(payload));
        
        return new OrderAddedPayload(order);
    } 
}