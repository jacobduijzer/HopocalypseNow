namespace HopocalypseNow.Frontend.BlazorApp;

public class OrderItem
{
    public Guid BeerId { get; set; }
    public int Amount { get; set; }

    public static OrderItem From(GraphQL.IGetAllBeers_Beers beer) =>
        new OrderItem()
        {
            BeerId = beer.BeerId,
            Amount = 0
        };
}