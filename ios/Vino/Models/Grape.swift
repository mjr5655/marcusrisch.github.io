import Foundation

/// A grape / wine type with a simple 1–5 "structure" profile used for recommendations.
struct Grape: Identifiable, Hashable {
    let id: String
    let style: WineStyle
    /// 1 (light) ... 5 (full)
    let body: Int
    /// 1 (soft) ... 5 (zippy)
    let acidity: Int
    /// 1 (none/silky) ... 5 (grippy)
    let tannin: Int
    /// 1 (bone dry) ... 5 (very sweet)
    let sweetness: Int
    let flavors: [String]
    let regions: [String]
    let pairings: [String]
    let summary: String
    let tip: String
    var aliases: [String] = []

    var name: String { id }

    var bodyWord: String { Grape.bodyWords[clamp(body)] }
    var acidityWord: String { Grape.acidityWords[clamp(acidity)] }
    var tanninWord: String { Grape.tanninWords[clamp(tannin)] }
    var sweetnessWord: String { Grape.sweetnessWords[clamp(sweetness)] }

    private func clamp(_ v: Int) -> Int { min(max(v, 1), 5) - 1 }

    static let bodyWords = ["light-bodied", "light-to-medium bodied", "medium-bodied", "medium-to-full bodied", "full-bodied"]
    static let acidityWords = ["soft", "gentle", "balanced", "bright", "zippy"]
    static let tanninWords = ["silky", "smooth", "moderate", "firm", "grippy"]
    static let sweetnessWords = ["bone dry", "dry", "off-dry", "sweet", "very sweet"]
}

enum GrapeCatalog {
    static func match(_ text: String) -> Grape? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard t.count >= 3 else { return nil }
        for grape in all {
            let names = ([grape.name] + grape.aliases).map { $0.lowercased() }
            if names.contains(where: { $0 == t || t.contains($0) || $0.contains(t) }) {
                return grape
            }
        }
        return nil
    }

    static let all: [Grape] = [
        Grape(
            id: "Pinot Noir", style: .red, body: 2, acidity: 4, tannin: 2, sweetness: 1,
            flavors: ["cherry", "raspberry", "mushroom", "forest floor", "baking spice"],
            regions: ["Burgundy, France", "Oregon", "Sonoma, California", "Central Otago, New Zealand"],
            pairings: ["salmon", "duck", "mushroom", "roast chicken", "pork", "charcuterie"],
            summary: "Silky, red-fruited and elegant. It's the classic 'light red' that still has real depth.",
            tip: "Serve slightly cool (about 60°F). Great gateway red if you usually prefer white.",
            aliases: ["Pinot Nero", "Spätburgunder"]
        ),
        Grape(
            id: "Cabernet Sauvignon", style: .red, body: 5, acidity: 4, tannin: 5, sweetness: 1,
            flavors: ["blackcurrant", "black cherry", "cedar", "tobacco", "dark chocolate"],
            regions: ["Napa Valley, California", "Bordeaux, France", "Coonawarra, Australia", "Maipo, Chile"],
            pairings: ["steak", "lamb", "burger", "aged cheddar", "short ribs", "bbq"],
            summary: "Powerful, structured and age-worthy. Firm tannins make it shine with rich, fatty meat.",
            tip: "Decant young bottles for 30–60 minutes. Tannins soften with food and time.",
            aliases: ["Cab Sav", "Cabernet"]
        ),
        Grape(
            id: "Merlot", style: .red, body: 4, acidity: 3, tannin: 3, sweetness: 1,
            flavors: ["plum", "black cherry", "cocoa", "vanilla", "herbs"],
            regions: ["Bordeaux (Right Bank), France", "Washington State", "Tuscany, Italy", "Chile"],
            pairings: ["roast chicken", "pork", "pasta", "burger", "mushroom", "meatloaf"],
            summary: "Plush and approachable, with softer tannins than Cabernet. Easy to love.",
            tip: "A crowd-pleasing red for dinner parties, since few people dislike it."
        ),
        Grape(
            id: "Syrah", style: .red, body: 5, acidity: 3, tannin: 4, sweetness: 1,
            flavors: ["blackberry", "black pepper", "smoke", "olive", "violet"],
            regions: ["Northern Rhône, France", "Barossa Valley, Australia", "Washington State", "Paso Robles, California"],
            pairings: ["bbq", "lamb", "grilled meat", "sausage", "stew", "peppery steak"],
            summary: "Dark, savory and spicy. Called Shiraz in Australia, where it's usually riper and juicier.",
            tip: "French Syrah tends to be peppery and savory; Australian Shiraz is plusher and fruitier.",
            aliases: ["Shiraz"]
        ),
        Grape(
            id: "Malbec", style: .red, body: 4, acidity: 3, tannin: 4, sweetness: 1,
            flavors: ["blackberry", "plum", "violet", "cocoa", "leather"],
            regions: ["Mendoza, Argentina", "Cahors, France"],
            pairings: ["steak", "empanadas", "grilled meat", "burger", "chimichurri", "bbq"],
            summary: "Inky and juicy with velvety fruit. Argentina's signature red and a steakhouse favorite.",
            tip: "Often great value. Look for Mendoza bottles at $15–25."
        ),
        Grape(
            id: "Sangiovese", style: .red, body: 3, acidity: 5, tannin: 4, sweetness: 1,
            flavors: ["sour cherry", "tomato leaf", "dried herbs", "leather", "orange peel"],
            regions: ["Chianti, Italy", "Brunello di Montalcino, Italy", "Tuscany, Italy"],
            pairings: ["pizza", "tomato sauce", "pasta", "lasagna", "parmesan", "grilled sausage"],
            summary: "Bright, savory and mouthwatering. Chianti's main grape, built for tomato-based food.",
            tip: "High acidity is why it loves tomato sauce. Match acidity with acidity."
        ),
        Grape(
            id: "Tempranillo", style: .red, body: 4, acidity: 3, tannin: 4, sweetness: 1,
            flavors: ["cherry", "leather", "tobacco", "dill", "vanilla"],
            regions: ["Rioja, Spain", "Ribera del Duero, Spain", "Douro, Portugal"],
            pairings: ["tapas", "chorizo", "manchego", "lamb", "grilled meat", "paella"],
            summary: "Spain's noble red: cherry fruit, leather and oak spice. Rioja labels (Crianza, Reserva) tell you how long it aged.",
            tip: "Crianza is the youngest and freshest style, and Gran Reserva is the most aged."
        ),
        Grape(
            id: "Zinfandel", style: .red, body: 4, acidity: 3, tannin: 3, sweetness: 2,
            flavors: ["jammy blackberry", "strawberry", "black pepper", "sweet tobacco"],
            regions: ["Lodi, California", "Sonoma, California", "Paso Robles, California", "Puglia, Italy (as Primitivo)"],
            pairings: ["bbq", "pizza", "burger", "ribs", "pulled pork", "spicy sausage"],
            summary: "Big, ripe and jammy with a touch of spice. California's heritage grape, a barbecue superstar.",
            tip: "Not to be confused with sweet 'White Zin', which is a pink wine.",
            aliases: ["Primitivo"]
        ),
        Grape(
            id: "Grenache", style: .red, body: 3, acidity: 2, tannin: 2, sweetness: 1,
            flavors: ["strawberry", "raspberry", "white pepper", "orange peel", "herbs"],
            regions: ["Southern Rhône, France", "Priorat & Rioja, Spain (Garnacha)", "Barossa Valley, Australia"],
            pairings: ["roast chicken", "pork", "lamb", "ratatouille", "charcuterie", "sausage"],
            summary: "Juicy, warm and fruity with low tannin. The backbone of Châteauneuf-du-Pape.",
            tip: "Often blended (GSM = Grenache, Syrah, Mourvèdre).",
            aliases: ["Garnacha", "Châteauneuf"]
        ),
        Grape(
            id: "Nebbiolo", style: .red, body: 4, acidity: 5, tannin: 5, sweetness: 1,
            flavors: ["rose petal", "tar", "cherry", "licorice", "dried herbs"],
            regions: ["Barolo, Italy", "Barbaresco, Italy", "Piedmont, Italy"],
            pairings: ["truffle", "mushroom risotto", "braised beef", "aged cheese", "game"],
            summary: "Pale in color but massive in structure. Barolo and Barbaresco are 'tar and roses' wines that reward patience.",
            tip: "Young Barolo can be austere. Give it years in the cellar or a long decant."
        ),
        Grape(
            id: "Chardonnay", style: .white, body: 3, acidity: 3, tannin: 1, sweetness: 1,
            flavors: ["apple", "lemon", "butter", "vanilla", "toast"],
            regions: ["Burgundy, France", "Chablis, France", "Sonoma, California", "Margaret River, Australia"],
            pairings: ["lobster", "roast chicken", "creamy pasta", "crab", "salmon", "corn"],
            summary: "A chameleon. Unoaked (Chablis) is crisp and mineral, while oaked California styles are rich and buttery.",
            tip: "If you dislike 'buttery', look for 'unoaked' or Chablis. If you love it, try Sonoma or Napa."
        ),
        Grape(
            id: "Sauvignon Blanc", style: .white, body: 2, acidity: 5, tannin: 1, sweetness: 1,
            flavors: ["grapefruit", "lime", "green apple", "cut grass", "passion fruit"],
            regions: ["Marlborough, New Zealand", "Loire Valley, France", "Bordeaux, France", "Chile"],
            pairings: ["goat cheese", "salad", "oysters", "shrimp", "asparagus", "sushi", "thai"],
            summary: "Zesty, herbal and refreshing. A classic with goat cheese and anything green.",
            tip: "Serve very cold. New Zealand is tropical and punchy, while Sancerre is flinty and restrained.",
            aliases: ["Sancerre", "Fumé Blanc"]
        ),
        Grape(
            id: "Riesling", style: .white, body: 2, acidity: 5, tannin: 1, sweetness: 3,
            flavors: ["lime", "green apple", "peach", "honey", "petrol (with age)"],
            regions: ["Mosel, Germany", "Alsace, France", "Finger Lakes, New York", "Clare Valley, Australia"],
            pairings: ["spicy food", "thai", "indian", "pork", "sushi", "ham", "curry"],
            summary: "Aromatic and electric. It ranges from bone dry to dessert sweet, with racy acidity keeping it balanced.",
            tip: "On German labels, Trocken = dry, Kabinett and Spätlese = progressively sweeter. Sweet Riesling tames spicy food."
        ),
        Grape(
            id: "Pinot Grigio", style: .white, body: 2, acidity: 3, tannin: 1, sweetness: 1,
            flavors: ["pear", "lemon", "green apple", "almond", "melon"],
            regions: ["Veneto & Friuli, Italy", "Alsace, France (as Pinot Gris)", "Oregon"],
            pairings: ["light seafood", "salad", "shrimp", "chicken", "risotto", "appetizers"],
            summary: "Light, crisp and easy. Italian Pinot Grigio is simple and refreshing, while Alsace Pinot Gris is richer.",
            tip: "A porch-sipper. For more character, look for Friuli or Alto Adige.",
            aliases: ["Pinot Gris"]
        ),
        Grape(
            id: "Chenin Blanc", style: .white, body: 3, acidity: 5, tannin: 1, sweetness: 2,
            flavors: ["quince", "apple", "honey", "chamomile", "wet wool"],
            regions: ["Vouvray & Loire Valley, France", "Stellenbosch, South Africa"],
            pairings: ["pork", "roast chicken", "curry", "creamy sauce", "fried chicken", "apple"],
            summary: "Versatile and underrated: dry, off-dry, sparkling or sweet, always with vivid acidity.",
            tip: "South African 'Steen' is the best-value Chenin."
        ),
        Grape(
            id: "Albariño", style: .white, body: 2, acidity: 4, tannin: 1, sweetness: 1,
            flavors: ["peach", "lemon", "saline", "grapefruit", "almond"],
            regions: ["Rías Baixas, Spain", "Vinho Verde, Portugal (as Alvarinho)"],
            pairings: ["shellfish", "oysters", "ceviche", "grilled fish", "shrimp", "tapas"],
            summary: "Crisp, citrusy and slightly salty. Made for seafood by the Atlantic coast.",
            tip: "If you like Sauvignon Blanc but want something rounder, try this.",
            aliases: ["Alvarinho"]
        ),
        Grape(
            id: "Viognier", style: .white, body: 4, acidity: 2, tannin: 1, sweetness: 2,
            flavors: ["peach", "apricot", "honeysuckle", "tangerine", "ginger"],
            regions: ["Condrieu, France", "Virginia", "Central Coast, California"],
            pairings: ["curry", "thai", "roast pork", "lobster", "butternut squash", "spicy shrimp"],
            summary: "Lush, floral and perfumed with a rich texture. It smells sweeter than it tastes.",
            tip: "Drink young and not too cold. The aromatics fade with age."
        ),
        Grape(
            id: "Moscato", style: .white, body: 1, acidity: 3, tannin: 1, sweetness: 5,
            flavors: ["orange blossom", "peach", "honeysuckle", "grape", "lychee"],
            regions: ["Piedmont, Italy (Moscato d'Asti)", "Alsace, France", "Australia"],
            pairings: ["fruit", "dessert", "brunch", "spicy food", "pastry", "blue cheese"],
            summary: "Sweet, low-alcohol and fragrant, often lightly fizzy. A perfect brunch or dessert wine.",
            tip: "Moscato d'Asti is often only ~5.5% ABV. Pour it cold.",
            aliases: ["Muscat", "Moscato d'Asti"]
        ),
        Grape(
            id: "Gewürztraminer", style: .white, body: 3, acidity: 2, tannin: 1, sweetness: 3,
            flavors: ["lychee", "rose petal", "ginger", "grapefruit", "spice"],
            regions: ["Alsace, France", "Alto Adige, Italy", "Anderson Valley, California"],
            pairings: ["thai", "indian", "spicy food", "washed-rind cheese", "ham", "asian"],
            summary: "Exotic and intensely perfumed. The 'lychee and roses' grape that tames spicy dishes.",
            tip: "Hard to spell, easy to love. Serve with takeout.",
            aliases: ["Gewurztraminer"]
        ),
        Grape(
            id: "Provence Rosé", style: .rose, body: 2, acidity: 4, tannin: 1, sweetness: 1,
            flavors: ["strawberry", "watermelon", "citrus", "herbs", "white peach"],
            regions: ["Provence, France", "Tavel, France", "Spain (Rosado)"],
            pairings: ["salad", "grilled fish", "charcuterie", "mediterranean", "goat cheese", "sushi", "picnic"],
            summary: "Pale, dry and crisp. Real rosé is serious, refreshing wine, not just sweet pink drink.",
            tip: "Drink the youngest vintage you can find, ideally within a year or two.",
            aliases: ["Rosé", "Rose", "Rosado"]
        ),
        Grape(
            id: "Champagne", style: .sparkling, body: 2, acidity: 5, tannin: 1, sweetness: 1,
            flavors: ["green apple", "lemon", "brioche", "almond", "chalk"],
            regions: ["Champagne, France", "Cava, Spain", "Crémant, France", "English sparkling wine"],
            pairings: ["oysters", "fried food", "popcorn", "caviar", "soft cheese", "celebration"],
            summary: "Made by the traditional method with a second fermentation in the bottle, giving fine bubbles and toasty complexity.",
            tip: "On labels: Brut = dry, Extra Dry = slightly sweeter (confusingly), Brut Nature = driest.",
            aliases: ["Cava", "Crémant", "Sparkling"]
        ),
        Grape(
            id: "Prosecco", style: .sparkling, body: 1, acidity: 4, tannin: 1, sweetness: 2,
            flavors: ["green apple", "pear", "honeysuckle", "citrus", "white peach"],
            regions: ["Veneto, Italy", "Friuli, Italy"],
            pairings: ["brunch", "appetizers", "prosciutto", "fruit", "light seafood", "aperitivo"],
            summary: "Fruity, fresh and fizzy. Made in tanks, so it's fruitier and cheaper than Champagne and best young.",
            tip: "Perfect for spritzes and brunch. Drink within a year or two of release."
        ),
    ]
}
