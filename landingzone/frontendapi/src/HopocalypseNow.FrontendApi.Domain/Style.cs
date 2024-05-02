namespace HopocalypseNow.FrontendApi.Models;

public class Style
{
    public Guid StyleId { get; set; } = Guid.NewGuid();
    public string Name { get; set; }
    
    public List<Beer> Beers { get; set; } = new List<Beer>(); 
}