import Foundation

/// A minimal, UI-independent view of a tasting so the recommender is easy to test.
struct TastedWine {
    let grape: String
    let rating: Double
}

struct TasteProfile: Equatable {
    var body: Double
    var acidity: Double
    var tannin: Double
    var sweetness: Double
}

struct Recommendation: Identifiable {
    let grape: Grape
    let score: Double
    let reason: String
    var id: String { grape.id }
}

enum Recommender {
    /// Ratings at or above this count as "liked".
    static let likeThreshold = 3.5
    /// Ratings at or below this (but above 0) count as "disliked".
    static let dislikeThreshold = 2.5

    private static let starterNames = [
        "Pinot Noir", "Sauvignon Blanc", "Chardonnay", "Malbec", "Riesling", "Prosecco",
    ]

    // MARK: Profile

    /// Average structure (body / acidity / tannin / sweetness) of the grapes you've liked,
    /// weighted by how much you liked them. Returns nil if there's nothing to learn from yet.
    static func profile(from tastings: [TastedWine]) -> TasteProfile? {
        var weightSum = 0.0
        var body = 0.0, acidity = 0.0, tannin = 0.0, sweetness = 0.0
        for t in tastings where t.rating >= likeThreshold {
            guard let g = GrapeCatalog.match(t.grape) else { continue }
            let w = t.rating - 2.5 // 4 → 1.5, 5 → 2.5
            weightSum += w
            body += Double(g.body) * w
            acidity += Double(g.acidity) * w
            tannin += Double(g.tannin) * w
            sweetness += Double(g.sweetness) * w
        }
        guard weightSum > 0 else { return nil }
        return TasteProfile(
            body: body / weightSum,
            acidity: acidity / weightSum,
            tannin: tannin / weightSum,
            sweetness: sweetness / weightSum
        )
    }

    // MARK: Recommendations

    static func recommend(from tastings: [TastedWine], limit: Int = 5) -> [Recommendation] {
        let rated = tastings.compactMap { t -> (Grape, Double)? in
            guard t.rating > 0, let g = GrapeCatalog.match(t.grape) else { return nil }
            return (g, t.rating)
        }
        let liked = rated.filter { $0.1 >= likeThreshold }
        let disliked = rated.filter { $0.1 <= dislikeThreshold }
        let alreadyTried = Set(rated.map { $0.0.id })

        guard !liked.isEmpty else { return starters(excluding: alreadyTried, limit: limit) }

        var results: [Recommendation] = []
        for candidate in GrapeCatalog.all where !alreadyTried.contains(candidate.id) {
            // Weighted similarity to the wines you've liked.
            var simSum = 0.0, weightSum = 0.0
            var nearest: (grape: Grape, sim: Double)?
            for (g, rating) in liked {
                let s = similarity(candidate, g)
                let w = rating - 2.5
                simSum += s * w
                weightSum += w
                if nearest == nil || s > nearest!.sim { nearest = (g, s) }
            }
            var score = simSum / weightSum

            // Small boost for styles you tend to like (reds vs. whites, etc.).
            let styleWeight = liked.filter { $0.0.style == candidate.style }.map { $0.1 - 2.5 }.reduce(0, +)
            let totalWeight = liked.map { $0.1 - 2.5 }.reduce(0, +)
            score += 0.1 * (styleWeight / totalWeight)

            // Penalty for being very close to something you disliked.
            if let worst = disliked.map({ similarity(candidate, $0.0) }).max() {
                score -= 0.4 * max(0, worst - 0.5)
            }

            guard let nearest else { continue }
            results.append(Recommendation(
                grape: candidate,
                score: score,
                reason: reason(for: candidate, similarTo: nearest.grape)
            ))
        }

        return Array(results.sorted { $0.score > $1.score }.prefix(limit))
    }

    private static func starters(excluding tried: Set<String>, limit: Int) -> [Recommendation] {
        starterNames
            .compactMap { name in GrapeCatalog.all.first { $0.name == name } }
            .filter { !tried.contains($0.id) }
            .prefix(limit)
            .map {
                Recommendation(
                    grape: $0,
                    score: 0,
                    reason: "A great place to start: \($0.bodyWord), \($0.acidityWord) acidity."
                )
            }
    }

    // MARK: Similarity & wording

    /// 0...1, where 1 is identical structure. Different styles (red vs. white) are slightly penalized.
    static func similarity(_ a: Grape, _ b: Grape) -> Double {
        let diffs = [
            abs(a.body - b.body),
            abs(a.acidity - b.acidity),
            abs(a.tannin - b.tannin),
            abs(a.sweetness - b.sweetness),
        ]
        let distance = Double(diffs.reduce(0, +)) / Double(diffs.count * 4)
        return max(0, 1 - distance)
    }

    private static func reason(for candidate: Grape, similarTo favorite: Grape) -> String {
        var shared: [String] = []
        if abs(candidate.body - favorite.body) <= 1 { shared.append(candidate.bodyWord) }
        if abs(candidate.acidity - favorite.acidity) <= 1 { shared.append("\(candidate.acidityWord) acidity") }
        if candidate.style == .red, favorite.style == .red, abs(candidate.tannin - favorite.tannin) <= 1 {
            shared.append("\(candidate.tanninWord) tannins")
        }
        if abs(candidate.sweetness - favorite.sweetness) <= 1 { shared.append(candidate.sweetnessWord) }
        let traits = shared.isEmpty ? "a similar overall feel" : shared.joined(separator: ", ")
        return "Because you liked \(favorite.name): \(traits)."
    }

    // MARK: Food pairing

    /// Finds grapes whose pairing list matches words in the query ("grilled salmon", "spicy thai").
    static func grapes(forFood query: String) -> [Grape] {
        let tokens = query
            .lowercased()
            .split(whereSeparator: { !$0.isLetter })
            .map(String.init)
            .filter { $0.count >= 3 }
        guard !tokens.isEmpty else { return [] }

        let scored: [(Grape, Int)] = GrapeCatalog.all.map { grape in
            let hits = tokens.filter { token in
                grape.pairings.contains { $0.contains(token) || token.contains($0) }
            }.count
            return (grape, hits)
        }
        return scored
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }
}
