namespace HopocalypseNow.DataFeeder;

public class BeerNameGenerator
{
    private static Random random = new Random();

    private static string[] prefixes =
        { "Hoppy", "Golden", "Dark", "Crisp", "Smooth", "Bold", "Sour", "Fruity", "Spicy", "Cloudy" };

    private static string[] adjectives =
        { "Amber", "Bitter", "Velvet", "Smokey", "Zesty", "Tangy", "Caramel", "Robust", "Creamy", "Toasty" };

    private static string[] nouns =
        { "Ale", "Stout", "Porter", "Lager", "Pilsner", "IPA", "Saison", "Wheat", "Barleywine", "Gose" };

    public static string GenerateBeerName()
    {
        string prefix = GetRandomWord(prefixes);
        string adjective = GetRandomWord(adjectives);
        string noun = GetRandomWord(nouns);

        prefix = CapitalizeFirstLetter(prefix);
        adjective = CapitalizeFirstLetter(adjective);
        noun = CapitalizeFirstLetter(noun);

        return $"{prefix} {adjective} {noun}";
    }

    // Helper method to get a random word from an array
    private static string GetRandomWord(string[] words)
    {
        return words[random.Next(0, words.Length)];
    }

    // Helper method to capitalize the first letter of a word
    private static string CapitalizeFirstLetter(string word)
    {
        if (string.IsNullOrEmpty(word))
            return string.Empty;

        return char.ToUpper(word[0]) + word.Substring(1);
    }
}