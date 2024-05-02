namespace HopocalypseNow.FrontendApi.Models;

public class Beer
{
    public Guid BeerId { get; set; }
    public string Name { get; set; }
    
    public Guid BreweryId { get; set; }
    public Brewery Brewery { get; set; } = new Brewery();
    
    public Guid StyleId { get; set; }
    public Style Style { get; set; } = new Style();
    
    public double Abv { get; set; } = 0;
    public double Ibu { get; set; } = 0;
    public string Description { get; set; } = string.Empty;
}