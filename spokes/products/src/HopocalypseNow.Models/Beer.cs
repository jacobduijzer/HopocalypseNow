namespace HopocalypseNow.Models;

public class Beer
{
    public Guid BeerId { get; set; }
    public string Name { get; set; }
    public Brewery Brewery { get; set; } = new Brewery();
    public Style Style { get; set; } = new Style();
    public double Abv { get; set; }
    public double Ibu { get; set; }
    public decimal Price { get; set; }
    public string Description { get; set; }
}