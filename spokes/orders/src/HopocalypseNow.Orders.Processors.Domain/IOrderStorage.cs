namespace HopocalypseNow.Orders.Processors.Domain;

public interface IOrderStorage
{
    Task Store(Order order);

}