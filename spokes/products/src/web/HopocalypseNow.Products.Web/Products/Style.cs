namespace HopocalypseNow.Products.Web.Products;

public class Style
{
    public Guid StyleId { get; set; } = Guid.NewGuid();
    public string Name { get; set; }
    
    public ICollection<Beer> Beers { get; set; } = new List<Beer>();
}