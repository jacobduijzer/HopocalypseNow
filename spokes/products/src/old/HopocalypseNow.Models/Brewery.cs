namespace HopocalypseNow.Models;

public class Brewery
{
    public Guid BreweryId { get; set; } = Guid.NewGuid();
    
    public string Name { get; set; }
    
    public List<Beer> Beers { get; set; } = new List<Beer>();

    // private List<Beer> _beers = new List<Beer>();
    // public IEnumerable<Beer> Beers => _beers;
}