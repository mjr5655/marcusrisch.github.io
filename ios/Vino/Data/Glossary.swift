import Foundation

struct GlossaryTerm: Identifiable {
    let term: String
    let definition: String
    var id: String { term }
}

enum Glossary {
    static let terms: [GlossaryTerm] = [
        GlossaryTerm(term: "Acidity", definition: "The tart, mouthwatering quality in wine that makes it feel fresh. Think of lemonade."),
        GlossaryTerm(term: "AVA", definition: "American Viticultural Area: a legally defined US grape-growing region, such as Napa Valley."),
        GlossaryTerm(term: "Body", definition: "How heavy or light a wine feels in the mouth, from skim milk (light) to cream (full)."),
        GlossaryTerm(term: "Brut", definition: "A dry style of sparkling wine. 'Brut Nature' is the driest."),
        GlossaryTerm(term: "Cork taint", definition: "A musty, wet-cardboard smell caused by a chemical called TCA. The wine is flawed, so it's fine to send it back."),
        GlossaryTerm(term: "Corked", definition: "Shorthand for cork taint, not for bits of cork floating in your glass."),
        GlossaryTerm(term: "Cuvée", definition: "A specific blend or batch of wine."),
        GlossaryTerm(term: "Decanting", definition: "Pouring wine into another vessel to aerate it or separate sediment."),
        GlossaryTerm(term: "Dry", definition: "Having little to no residual sugar. The opposite of sweet."),
        GlossaryTerm(term: "Finish", definition: "The flavors and sensations that linger after you swallow. Longer is generally better."),
        GlossaryTerm(term: "Fortified", definition: "Wine with added spirit, such as port, sherry and Madeira."),
        GlossaryTerm(term: "Legs / tears", definition: "Streaks that run down the glass after swirling. They show alcohol or sugar level, not quality."),
        GlossaryTerm(term: "Malolactic fermentation", definition: "A secondary process converting sharp malic acid to softer lactic acid. It creates the buttery note in Chardonnay."),
        GlossaryTerm(term: "Mouthfeel", definition: "The tactile texture of wine: silky, creamy, grippy, oily, etc."),
        GlossaryTerm(term: "Nose", definition: "The aromas of a wine, i.e. what you smell."),
        GlossaryTerm(term: "Oaked", definition: "Aged in oak barrels, adding flavors of vanilla, toast, coconut or spice."),
        GlossaryTerm(term: "Old World / New World", definition: "Old World is traditional European regions (France, Italy, Spain). New World is everywhere else (USA, Australia, Argentina…)."),
        GlossaryTerm(term: "Appellation", definition: "A legally defined wine region, such as Chablis or Napa Valley, that implies rules about grapes and methods."),
        GlossaryTerm(term: "Residual sugar", definition: "Natural grape sugar left in the wine after fermentation stops."),
        GlossaryTerm(term: "Sommelier", definition: "A trained wine professional, usually in a restaurant."),
        GlossaryTerm(term: "Sulfites", definition: "Preservatives that occur naturally and are usually added in small amounts. Red wines contain fewer than many dried fruits."),
        GlossaryTerm(term: "Tannin", definition: "A compound from grape skins, seeds and oak that gives a drying, grippy feeling. It's found mostly in reds."),
        GlossaryTerm(term: "Terroir", definition: "The combined effect of soil, climate and landscape on a wine's character."),
        GlossaryTerm(term: "Varietal", definition: "A wine made primarily from one grape, such as a Merlot varietal."),
        GlossaryTerm(term: "Vintage", definition: "The year the grapes were harvested."),
    ]
}
