namespace HopocalypseNow.Products.Web.Products;

public class Brewery
{
    public Guid BreweryId { get; set; } = Guid.NewGuid();
    
    public string Name { get; set; }
    
    public List<Beer> Beers { get; set; } = new List<Beer>();
}