import Foundation
import SwiftData

enum WineStyle: String, Codable, CaseIterable, Identifiable {
    case red = "Red"
    case white = "White"
    case rose = "Rosé"
    case sparkling = "Sparkling"
    case dessert = "Dessert"
    case orange = "Orange"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .red: return "wineglass.fill"
        case .white: return "wineglass"
        case .rose: return "drop.fill"
        case .sparkling: return "sparkles"
        case .dessert: return "birthday.cake"
        case .orange: return "sun.max.fill"
        }
    }
}

@Model
final class Wine {
    var name: String = ""
    var producer: String = ""
    var vintage: Int?
    var grape: String = ""
    var region: String = ""
    var country: String = ""
    var styleRaw: String = WineStyle.red.rawValue
    var price: Double?
    /// 0 means "not rated yet", otherwise 1...5.
    var rating: Double = 0
    var notes: String = ""
    var dateAdded: Date = Date.now
    var isWishlist: Bool = false
    /// Empty string means "both of us"; otherwise the name of whoever tasted it.
    var taster: String = ""

    var style: WineStyle {
        get { WineStyle(rawValue: styleRaw) ?? .red }
        set { styleRaw = newValue.rawValue }
    }

    var displayName: String {
        name.isEmpty ? (grape.isEmpty ? "Untitled wine" : grape) : name
    }

    var subtitle: String {
        [producer, vintage.map { String($0) }]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    var catalogGrape: Grape? { GrapeCatalog.match(grape) }

    init(
        name: String = "",
        producer: String = "",
        vintage: Int? = nil,
        grape: String = "",
        region: String = "",
        country: String = "",
        style: WineStyle = .red,
        price: Double? = nil,
        rating: Double = 0,
        notes: String = "",
        taster: String = "",
        isWishlist: Bool = false
    ) {
        self.name = name
        self.producer = producer
        self.vintage = vintage
        self.grape = grape
        self.region = region
        self.country = country
        self.styleRaw = style.rawValue
        self.price = price
        self.rating = rating
        self.notes = notes
        self.taster = taster
        self.isWishlist = isWishlist
        self.dateAdded = .now
    }
}
