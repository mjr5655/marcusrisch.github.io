import Foundation

/// One line of text read from a label, with its relative height (a proxy for font size).
struct RecognizedLine: Equatable {
    var text: String
    var height: Double = 0.02
    /// Normalized (0...1) bounding box in Vision's bottom-left-origin coordinates. `.zero` if unknown.
    var box: CGRect = .zero
}

struct ScannedWine: Equatable {
    var name = ""
    var producer = ""
    var grape = ""
    var region = ""
    var country = ""
    var vintage: Int?
    var style: WineStyle?

    var isEmpty: Bool {
        name.isEmpty && producer.isEmpty && grape.isEmpty && region.isEmpty
            && country.isEmpty && vintage == nil && style == nil
    }

    /// Copies scanned values into the wine, but never overwrites text the user already typed.
    func fillEmptyFields(of wine: Wine) {
        if wine.name.isEmpty, !name.isEmpty { wine.name = name }
        if wine.producer.isEmpty, !producer.isEmpty { wine.producer = producer }
        if wine.grape.isEmpty, !grape.isEmpty { wine.grape = grape }
        if wine.region.isEmpty, !region.isEmpty { wine.region = region }
        if wine.country.isEmpty, !country.isEmpty { wine.country = country }
        if wine.vintage == nil, let vintage { wine.vintage = vintage }
        if let style { wine.style = style }
    }
}

/// Turns raw OCR lines from a wine label into structured fields. Pure and testable.
/// Labels vary wildly, so this is a best-effort heuristic; the user always reviews the result.
enum LabelParser {
    static func parse(
        _ lines: [RecognizedLine],
        currentYear: Int = Calendar.current.component(.year, from: Date())
    ) -> ScannedWine {
        var result = ScannedWine()
        let cleaned = lines
            .map { RecognizedLine(text: $0.text.trimmingCharacters(in: .whitespacesAndNewlines), height: $0.height) }
            .filter { !$0.text.isEmpty }
        guard !cleaned.isEmpty else { return result }

        let joined = fold(cleaned.map(\.text).joined(separator: "\n"))

        // Vintage
        result.vintage = vintage(in: cleaned, currentYear: currentYear)

        // Grape
        let grapeMatch = findGrape(in: joined)
        result.grape = grapeMatch?.grape.name ?? ""

        // Region & country
        let regionIndex = bestMatch(in: joined, names: regions.map { $0.name })
        let regionEntry = regionIndex.map { regions[$0] }
        result.region = regionEntry?.name ?? ""
        let countryIndex = bestMatch(in: joined, names: countries.map { $0.name })
        result.country = countryIndex.map { countries[$0].country } ?? regionEntry?.country ?? ""

        // Style
        if containsWord("rose", in: joined) {
            result.style = .rose
        } else if sparklingWords.contains(where: { containsWord($0, in: joined) }) {
            result.style = .sparkling
        } else if let grape = grapeMatch?.grape {
            result.style = grape.style
        } else if whiteWords.contains(where: { containsWord($0, in: joined) }) {
            result.style = .white
        } else if redWords.contains(where: { containsWord($0, in: joined) }) {
            result.style = .red
        }

        // Producer & name: whatever lines remain once we remove the facts we already extracted.
        let found = [
            grapeMatch?.matched,
            regionEntry?.name,
            countryIndex.map { countries[$0].name },
            result.vintage.map(String.init),
        ]
        .compactMap { $0 }
        .map(fold)
        .sorted { $0.count > $1.count } // strip longer phrases first so partial overlaps don't leave debris

        let candidates = cleaned.filter { line in
            guard !isNoise(line.text) else { return false }
            var s = fold(line.text)
            for f in found { s = s.replacingOccurrences(of: f, with: " ") }
            s = s.replacingOccurrences(of: "[^\\p{L} ]", with: " ", options: .regularExpression)
            let words = s.split(separator: " ").map(String.init).filter { !filler.contains($0) }
            return words.joined().count >= 3
        }

        let producerIndex = candidates.firstIndex {
            fold($0.text).range(of: producerKeywords, options: .regularExpression) != nil
        } ?? candidates.indices.max { candidates[$0].height < candidates[$1].height }

        if let producerIndex {
            result.producer = tidy(candidates[producerIndex].text)
            let rest = candidates.indices.filter { $0 != producerIndex }
            if let nameIndex = rest.max(by: { candidates[$0].height < candidates[$1].height }) {
                result.name = tidy(candidates[nameIndex].text)
            }
        }
        return result
    }

    // MARK: Vintage

    static func vintage(in lines: [RecognizedLine], currentYear: Int) -> Int? {
        let regex = try? NSRegularExpression(pattern: "\\b(19[5-9][0-9]|20[0-3][0-9])\\b")
        var years: [Int] = []
        for line in lines {
            let lower = line.text.lowercased()
            // "Est. 1985" is a founding year, not a vintage.
            if ["est", "since", "founded", "established"].contains(where: { containsWord($0, in: lower) }) { continue }
            let range = NSRange(lower.startIndex..., in: lower)
            for match in regex?.matches(in: lower, range: range) ?? [] {
                if let r = Range(match.range(at: 1), in: lower), let year = Int(lower[r]) {
                    years.append(year)
                }
            }
        }
        return years.filter { $0 <= currentYear }.max()
    }

    // MARK: Grape

    static func findGrape(in foldedText: String) -> (grape: Grape, matched: String)? {
        var best: (grape: Grape, matched: String)?
        for grape in GrapeCatalog.all {
            for name in [grape.name] + grape.aliases where containsWord(fold(name), in: foldedText) {
                if best == nil || name.count > best!.matched.count {
                    best = (grape, name)
                }
            }
        }
        return best
    }

    // MARK: Helpers

    /// Lowercases and strips accents so "Château" matches "chateau".
    static func fold(_ s: String) -> String {
        s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
    }

    /// Whole-word match. Both arguments should already be folded/lowercased.
    static func containsWord(_ phrase: String, in text: String) -> Bool {
        let pattern = "(?<![\\p{L}])" + NSRegularExpression.escapedPattern(for: fold(phrase)) + "(?![\\p{L}])"
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    /// Index of the longest name that appears in the text.
    private static func bestMatch(in folded: String, names: [String]) -> Int? {
        var best: Int?
        for (i, name) in names.enumerated() where containsWord(fold(name), in: folded) {
            if best == nil || name.count > names[best!].count { best = i }
        }
        return best
    }

    private static func isNoise(_ text: String) -> Bool {
        fold(text).range(of: noisePattern, options: .regularExpression) != nil
    }

    /// Removes years and tidies ALL-CAPS OCR output into Title Case.
    private static func tidy(_ text: String) -> String {
        var t = text.replacingOccurrences(of: "\\b(19|20)\\d\\d\\b", with: "", options: .regularExpression)
        t = t.trimmingCharacters(in: .whitespacesAndNewlines.union(.punctuationCharacters))
        if t == t.uppercased(), t != t.lowercased() { t = t.capitalized }
        return t
    }

    // MARK: Tables

    private static let noisePattern =
        "(government|surgeon|sulfite|sulphite|contains|\\balc\\b|alc\\.|\\d+(\\.\\d+)?\\s*%|\\b\\d+\\s?(ml|cl)\\b|\\b\\d+(\\.\\d+)?\\s?l\\b|product of|produce of|imported|bottled|produced|mis en bouteille|embotellado|imbottigliato|www\\.|\\.com|pregnan|appellation|denominazione|\\ba\\.?o\\.?c\\.?\\b|\\bd\\.?o\\.?c\\.?g?\\b|\\bnet\\b)"

    private static let producerKeywords =
        "\\b(chateau|domaine|bodegas?|cantina|tenuta|weingut|cellars|winery|vineyards?|vina|maison|castello|clos|casa)\\b"

    private static let filler: Set<String> = [
        "reserve", "reserva", "riserva", "estate", "wine", "wines", "red", "white", "rose", "of", "the",
        "de", "del", "di", "la", "le", "valley", "vineyard", "vineyards", "winery", "cellars", "and",
        "by", "vol", "est", "brut",
    ]

    private static let sparklingWords = ["brut", "sparkling", "spumante", "cremant", "champagne", "prosecco", "cava", "espumante", "sekt"]
    private static let whiteWords = ["blanc", "white", "blanco", "bianco", "weiss"]
    private static let redWords = ["rouge", "red", "tinto", "rosso", "rot"]

    private static let countries: [(name: String, country: String)] = [
        ("France", "France"), ("Italy", "Italy"), ("Italia", "Italy"), ("Spain", "Spain"),
        ("España", "Spain"), ("Portugal", "Portugal"), ("Germany", "Germany"),
        ("Deutschland", "Germany"), ("Austria", "Austria"), ("Argentina", "Argentina"),
        ("Chile", "Chile"), ("Australia", "Australia"), ("New Zealand", "New Zealand"),
        ("South Africa", "South Africa"), ("United States", "USA"), ("USA", "USA"),
    ]

    private static let regions: [(name: String, country: String)] = [
        // USA
        ("Napa Valley", "USA"), ("Napa", "USA"), ("Sonoma", "USA"), ("Russian River Valley", "USA"),
        ("Paso Robles", "USA"), ("Willamette Valley", "USA"), ("Lodi", "USA"),
        ("Santa Barbara", "USA"), ("Finger Lakes", "USA"), ("California", "USA"), ("Oregon", "USA"),
        // France
        ("Bordeaux", "France"), ("Burgundy", "France"), ("Bourgogne", "France"), ("Chablis", "France"),
        ("Champagne", "France"), ("Sancerre", "France"), ("Loire Valley", "France"),
        ("Vouvray", "France"), ("Alsace", "France"), ("Provence", "France"),
        ("Châteauneuf-du-Pape", "France"), ("Côtes du Rhône", "France"), ("Rhône", "France"),
        ("Beaujolais", "France"), ("Languedoc", "France"), ("Cahors", "France"),
        // Italy
        ("Chianti Classico", "Italy"), ("Chianti", "Italy"), ("Brunello di Montalcino", "Italy"),
        ("Montalcino", "Italy"), ("Tuscany", "Italy"), ("Toscana", "Italy"), ("Barolo", "Italy"),
        ("Barbaresco", "Italy"), ("Piedmont", "Italy"), ("Piemonte", "Italy"), ("Veneto", "Italy"),
        ("Valpolicella", "Italy"), ("Sicily", "Italy"), ("Puglia", "Italy"), ("Friuli", "Italy"),
        ("Alto Adige", "Italy"),
        // Spain & Portugal
        ("Rioja", "Spain"), ("Ribera del Duero", "Spain"), ("Rías Baixas", "Spain"),
        ("Priorat", "Spain"), ("Rueda", "Spain"), ("Douro", "Portugal"), ("Vinho Verde", "Portugal"),
        // Germany & Austria
        ("Mosel", "Germany"), ("Rheingau", "Germany"), ("Pfalz", "Germany"), ("Wachau", "Austria"),
        // Southern Hemisphere
        ("Mendoza", "Argentina"), ("Maipo Valley", "Chile"), ("Colchagua", "Chile"),
        ("Casablanca Valley", "Chile"), ("Marlborough", "New Zealand"), ("Central Otago", "New Zealand"),
        ("Barossa Valley", "Australia"), ("Barossa", "Australia"), ("McLaren Vale", "Australia"),
        ("Margaret River", "Australia"), ("Clare Valley", "Australia"), ("Hunter Valley", "Australia"),
        ("Stellenbosch", "South Africa"), ("Swartland", "South Africa"),
    ]
}
