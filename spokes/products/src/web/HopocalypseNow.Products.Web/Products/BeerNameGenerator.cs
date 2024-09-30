namespace HopocalypseNow.Products.Web.Products;

public class BeerNameGenerator
{
    private static readonly Random Random = new Random();

    private static readonly string[] Prefixes =
        { "Hoppy", "Golden", "Dark", "Crisp", "Smooth", "Bold", "Sour", "Fruity", "Spicy", "Cloudy" };

    private static readonly string[] Adjectives =
        { "Amber", "Bitter", "Velvet", "Smokey", "Zesty", "Tangy", "Caramel", "Robust", "Creamy", "Toasty" };

    private static readonly string[] Nouns =
        { "Ale", "Stout", "Porter", "Lager", "Pilsner", "IPA", "Saison", "Wheat", "Barleywine", "Gose" };

    public static string GenerateBeerName()
    {
        string prefix = GetRandomWord(Prefixes);
        string adjective = GetRandomWord(Adjectives);
        string noun = GetRandomWord(Nouns);

        prefix = CapitalizeFirstLetter(prefix);
        adjective = CapitalizeFirstLetter(adjective);
        noun = CapitalizeFirstLetter(noun);

        return $"{prefix} {adjective} {noun}";
    }

    // Helper method to get a random word from an array
    private static string GetRandomWord(string[] words)
    {
        return words[Random.Next(0, words.Length)];
    }

    // Helper method to capitalize the first letter of a word
    private static string CapitalizeFirstLetter(string word)
    {
        if (string.IsNullOrEmpty(word))
            return string.Empty;

        return char.ToUpper(word[0]) + word[1..];
    }
}