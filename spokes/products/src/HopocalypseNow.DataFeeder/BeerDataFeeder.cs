using HopocalypseNow.Models;

namespace HopocalypseNow.DataFeeder;

public class BeerDataFeeder
{
    private List<Brewery> breweries;
    private List<Style> styles;

    public BeerDataFeeder()
    {
        // Sample Breweries
        breweries = new List<Brewery>
        {
            new Brewery { BreweryId = Guid.NewGuid(), Name = "Sample Brewery 1" },
            new Brewery { BreweryId = Guid.NewGuid(), Name = "Sample Brewery 2" },
            new Brewery { BreweryId = Guid.NewGuid(), Name = "Sample Brewery 3" }
        };

        // Sample Styles
        styles = new List<Style>
        {
            new Style { StyleId = Guid.NewGuid(), Name = "IPA" },
            new Style { StyleId = Guid.NewGuid(), Name = "Stout" },
            new Style { StyleId = Guid.NewGuid(), Name = "Pilsner" }
        };
    }

    public IEnumerable<Beer> GetRandomBeers(int count)
    {
        List<Beer> beers = new List<Beer>();

        Random random = new Random();
        for (int i = 0; i < count; i++)
        {
            Brewery randomBrewery = breweries[random.Next(breweries.Count)];
            Style randomStyle = styles[random.Next(styles.Count)];

            beers.Add(new Beer
            {
                BeerId = Guid.NewGuid(),
                Name = $"Beer {i + 1}",
                Brewery = randomBrewery,
                Style = randomStyle,
                Abv = GetRandomAbv(),
                Ibu = GetRandomIbu(),
                Description = $"A random beer with {randomStyle.Name} style from {randomBrewery.Name}."
            });
        }

        return beers;
    }

    private double GetRandomAbv()
    {
        // Generate a random alcohol by volume (ABV) between 4.0% and 10.0%
        Random random = new Random();
        return Math.Round(random.NextDouble() * (10.0 - 4.0) + 4.0, 1);
    }

    private int GetRandomIbu()
    {
        // Generate a random International Bitterness Unit (IBU) between 20 and 80
        Random random = new Random();
        return random.Next(20, 80);
    }
}