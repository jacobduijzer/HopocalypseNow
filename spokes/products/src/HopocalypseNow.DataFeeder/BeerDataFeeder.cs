using Bogus;
using HopocalypseNow.Models;

namespace HopocalypseNow.DataFeeder;

public class BeerDataFeeder
{
    private List<Brewery> breweries;
    private List<Style> styles;

    public BeerDataFeeder()
    {
        var faker = new Faker("en");

        // Sample Breweries
        breweries = new List<Brewery>
        {
            new Brewery { BreweryId = Guid.NewGuid(), Name = $"{faker.Company.CompanyName()} Brewery" },
            new Brewery { BreweryId = Guid.NewGuid(), Name = $"{faker.Company.CompanyName()} Brewery" },
            new Brewery { BreweryId = Guid.NewGuid(), Name = $"{faker.Company.CompanyName()} Brewery" }
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
            var abv = GetRandomAbv();
            var ibu = GetRandomIbu();
            beers.Add(new Beer
            {
                BeerId = Guid.NewGuid(),
                Name = BeerNameGenerator.GenerateBeerName(),
                Brewery = randomBrewery,
                Style = randomStyle,
                Abv = GetRandomAbv(),
                Ibu = GetRandomIbu(),
                Description = $"A random beer with {randomStyle.Name} style from {randomBrewery.Name}.",
                Price = (decimal)(abv + (ibu * 0.1))
            });
        }

        return beers;
    }

    private double GetRandomAbv()
    {
        // Generate a random alcohol by volume (ABV) between 4.0% and 12.0%
        Random random = new Random();
        return Math.Round(random.NextDouble() * (12.0 - 4.0) + 4.0, 1);
    }

    private int GetRandomIbu()
    {
        // Generate a random International Bitterness Unit (IBU) between 20 and 80
        Random random = new Random();
        return random.Next(20, 80);
    }
}