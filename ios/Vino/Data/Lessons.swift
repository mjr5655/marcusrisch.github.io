import Foundation

struct LessonSection: Identifiable {
    let id = UUID()
    let heading: String
    let body: String
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct Lesson: Identifiable {
    let id: String
    let title: String
    let icon: String
    let summary: String
    let sections: [LessonSection]
    let quiz: [QuizQuestion]
}

enum LessonLibrary {
    static let all: [Lesson] = [tasting, structure, labels, serving, pairing, regions]

    static var allQuestions: [QuizQuestion] { all.flatMap { $0.quiz } }

    static let tasting = Lesson(
        id: "tasting",
        title: "How to Taste Wine",
        icon: "eye",
        summary: "Look, swirl, smell, sip, think. Five steps that turn drinking into tasting.",
        sections: [
            LessonSection(heading: "1. Look", body: "Tilt the glass against something white. Color hints at age and grape: reds go from purple (young) to brick (older), while whites deepen from pale lemon to gold."),
            LessonSection(heading: "2. Swirl", body: "Swirling adds oxygen and releases aroma. Do it with the glass on the table at first, with no splashing."),
            LessonSection(heading: "3. Smell", body: "Take a short sniff, then a longer one. Start with broad families such as fruit, flower, spice, earth and oak, then get specific: cherry or plum? Citrus or tropical?"),
            LessonSection(heading: "4. Sip", body: "Let the wine coat your whole mouth. Notice sweetness, acidity (does your mouth water?), tannin (does it feel drying, like strong tea?), body (skim milk vs. whole milk) and alcohol warmth."),
            LessonSection(heading: "5. Think", body: "How long do the flavors last after you swallow? That's the finish, and a long finish usually signals quality. Then decide whether you like it, which is the only opinion that really matters."),
        ],
        quiz: [
            QuizQuestion(
                question: "What does a long finish usually indicate?",
                options: ["The wine is too old", "Higher quality", "More sugar", "It needs decanting"],
                correctIndex: 1,
                explanation: "Flavors that linger after you swallow are a classic sign of a well-made, complex wine."
            ),
            QuizQuestion(
                question: "Why do we swirl wine?",
                options: ["To cool it down", "To remove sediment", "To release aromas with oxygen", "To make it sweeter"],
                correctIndex: 2,
                explanation: "Swirling exposes more wine to air, which volatilizes the aroma compounds you smell."
            ),
        ]
    )

    static let structure = Lesson(
        id: "structure",
        title: "Body, Acidity, Tannin & Sweetness",
        icon: "slider.horizontal.3",
        summary: "The four dials that describe almost any wine, and how Vino learns your taste.",
        sections: [
            LessonSection(heading: "Body", body: "How heavy the wine feels. Think skim milk (light, e.g. Pinot Grigio) vs. whole milk (medium, e.g. Merlot) vs. cream (full, e.g. Cabernet). Alcohol and extract drive body."),
            LessonSection(heading: "Acidity", body: "The mouthwatering, tart quality, like lemonade. High-acid wines (Sauvignon Blanc, Riesling, Chianti) taste fresh and pair well with rich or salty food."),
            LessonSection(heading: "Tannin", body: "A drying, grippy texture in red wines that comes from grape skins, seeds and oak. Cabernet and Nebbiolo have a lot, while Pinot Noir and Grenache have little. Protein and fat in food, such as steak, soften tannin."),
            LessonSection(heading: "Sweetness", body: "Residual sugar left after fermentation. 'Dry' simply means little to no sugar. Fruity wines can smell sweet but taste dry, which confuses a lot of people."),
            LessonSection(heading: "Your taste profile", body: "When you rate wines 4 or 5 stars, Vino averages the body, acidity, tannin and sweetness of those grapes to build your profile, then suggests new grapes that match it."),
        ],
        quiz: [
            QuizQuestion(
                question: "Which component makes your mouth feel dry and grippy?",
                options: ["Acidity", "Tannin", "Sugar", "Alcohol"],
                correctIndex: 1,
                explanation: "Tannin binds to proteins in your saliva, creating that drying sensation."
            ),
            QuizQuestion(
                question: "What does 'dry' mean on a wine label or in tasting notes?",
                options: ["Little to no residual sugar", "Astringent", "High alcohol", "Aged a long time"],
                correctIndex: 0,
                explanation: "Dry is the opposite of sweet. A fruity wine can still be dry."
            ),
            QuizQuestion(
                question: "Which of these is typically the fullest-bodied?",
                options: ["Pinot Grigio", "Pinot Noir", "Cabernet Sauvignon", "Moscato"],
                correctIndex: 2,
                explanation: "Cabernet Sauvignon is a classic full-bodied, high-tannin red."
            ),
        ]
    )

    static let labels = Lesson(
        id: "labels",
        title: "Reading a Wine Label",
        icon: "tag",
        summary: "Old World vs. New World, and what the words on the bottle really tell you.",
        sections: [
            LessonSection(heading: "New World labels", body: "USA, Australia, Argentina, Chile, New Zealand and South Africa usually put the grape up front: 'Malbec' or 'Chardonnay'. It's simple and beginner-friendly."),
            LessonSection(heading: "Old World labels", body: "France, Italy and Spain often name the place instead: Chablis, Chianti, Rioja. The grape is implied by the region's rules. Chablis is Chardonnay, red Burgundy is Pinot Noir, Chianti is mostly Sangiovese, and Rioja is mostly Tempranillo."),
            LessonSection(heading: "Vintage", body: "The year the grapes were harvested, not bottled. It matters most in cool, variable climates (Burgundy, Champagne, Germany) and less in consistently sunny regions."),
            LessonSection(heading: "ABV", body: "Alcohol by volume is a clue to style. Under ~12% is usually light and crisp (or sweet), while 14.5% and up is typically rich and full-bodied."),
            LessonSection(heading: "Quality terms", body: "Reserva / Riserva / Reserve usually indicate extra aging (strictly regulated in Spain and Italy, but loosely used in the US). 'Old vines' (vieilles vignes) hints at concentration. 'Estate bottled' means the producer grew the grapes."),
        ],
        quiz: [
            QuizQuestion(
                question: "A bottle of red Burgundy is made from which grape?",
                options: ["Merlot", "Syrah", "Pinot Noir", "Malbec"],
                correctIndex: 2,
                explanation: "Red Burgundy is Pinot Noir. Old World labels name the place and assume you know the grape."
            ),
            QuizQuestion(
                question: "What does the vintage year on a label tell you?",
                options: ["When it was bottled", "When the grapes were harvested", "When to drink it by", "When the winery was founded"],
                correctIndex: 1,
                explanation: "Vintage is the harvest year."
            ),
        ]
    )

    static let serving = Lesson(
        id: "serving",
        title: "Serving & Storing",
        icon: "thermometer.medium",
        summary: "Temperature, glassware, decanting and keeping a bottle once it's open.",
        sections: [
            LessonSection(heading: "Temperature", body: "Most people serve reds too warm and whites too cold. Aim for: sparkling 40–45°F, light whites and rosé 45–50°F, full whites 50–55°F, light reds 55–60°F, full reds 60–65°F. Fridge a red for ~20 minutes before serving, and pull a white out ~20 minutes early."),
            LessonSection(heading: "Glassware", body: "You don't need a different glass for every grape. One decent all-purpose glass works for everything, with a bowl wide enough to swirl and a rim narrower than the bowl to catch aroma. Fill only a third."),
            LessonSection(heading: "Decanting", body: "Pouring into a wide vessel does two things: separates sediment from older bottles, and aerates young, tannic reds (like Cabernet or Barolo) so they open up. Most everyday whites don't need it."),
            LessonSection(heading: "Storing unopened bottles", body: "Keep them cool (~55°F ideal), dark and steady, away from heat and vibration. Lay corked bottles on their side. For wines you'll drink within a few weeks, a cool closet is fine."),
            LessonSection(heading: "Once it's open", body: "Re-cork and refrigerate, even reds. Most wines last 3–5 days. Sparkling lasts 1–3 days with a proper stopper. Fortified wines like port keep for weeks."),
        ],
        quiz: [
            QuizQuestion(
                question: "What's a good serving temperature for full-bodied red wine?",
                options: ["40°F", "50°F", "60–65°F", "75°F"],
                correctIndex: 2,
                explanation: "'Room temperature' originally meant a cool European room. Slightly cool brings out the fruit and balances alcohol."
            ),
            QuizQuestion(
                question: "How should you store a bottle of wine you've opened?",
                options: ["On the counter, uncorked", "Recorked in the fridge", "In the freezer", "Upright in the sun"],
                correctIndex: 1,
                explanation: "Cold slows oxidation. Take reds out for a bit before pouring again."
            ),
        ]
    )

    static let pairing = Lesson(
        id: "pairing",
        title: "Pairing Wine with Food",
        icon: "fork.knife",
        summary: "A few principles that beat memorizing a chart.",
        sections: [
            LessonSection(heading: "Match weight", body: "Light dishes go with light wines (sole and Pinot Grigio), and rich dishes with bigger wines (ribeye and Cabernet). Weight with weight is the most reliable rule."),
            LessonSection(heading: "Acidity loves acidity", body: "A tomato sauce needs a high-acid wine like Chianti, or it'll make the wine taste flat. Salad with vinaigrette works with Sauvignon Blanc."),
            LessonSection(heading: "Tannin loves fat & protein", body: "Steak, lamb and aged cheese soften tannins, so big reds taste smoother. Tannic reds with delicate fish can taste metallic."),
            LessonSection(heading: "Sweet beats heat", body: "Off-dry Riesling or Gewürztraminer cools down spicy food. High-alcohol, high-tannin wines make spice feel hotter."),
            LessonSection(heading: "Bubbles + salt/fat", body: "Sparkling wine cuts through salty, fried and creamy food. Champagne and fries is a famous pairing for a reason."),
            LessonSection(heading: "Regional pairs", body: "What grows together goes together: Chianti with Tuscan food, Albariño with Galician seafood, Sancerre with Loire goat cheese."),
        ],
        quiz: [
            QuizQuestion(
                question: "Which wine is the best match for spicy Thai food?",
                options: ["Big tannic Cabernet", "Off-dry Riesling", "Oaky Chardonnay", "High-alcohol Zinfandel"],
                correctIndex: 1,
                explanation: "A touch of sweetness and high acidity with low alcohol calms the heat."
            ),
            QuizQuestion(
                question: "Why does a juicy steak make Cabernet taste smoother?",
                options: ["Protein and fat soften tannin", "Salt hides acidity", "Steak adds sugar", "It doesn't"],
                correctIndex: 0,
                explanation: "Tannin binds to proteins and fats in food instead of your mouth."
            ),
            QuizQuestion(
                question: "Tomato-based pasta sauce pairs best with a wine that has…",
                options: ["Low acidity", "High acidity", "Lots of oak", "Residual sugar"],
                correctIndex: 1,
                explanation: "Acidic food needs an equally acidic wine, which is why Chianti is a classic with pasta."
            ),
        ]
    )

    static let regions = Lesson(
        id: "regions",
        title: "Key Regions to Know",
        icon: "map",
        summary: "A tour of the places behind famous bottles.",
        sections: [
            LessonSection(heading: "France", body: "Bordeaux (Cabernet/Merlot blends), Burgundy (Pinot Noir & Chardonnay), Champagne (sparkling), Rhône (Syrah & Grenache), Loire (Sauvignon Blanc, Chenin Blanc), Alsace (Riesling, Gewürztraminer)."),
            LessonSection(heading: "Italy", body: "Tuscany (Chianti, Brunello: Sangiovese), Piedmont (Barolo: Nebbiolo; Moscato d'Asti), Veneto (Prosecco, Amarone), Sicily (Nero d'Avola)."),
            LessonSection(heading: "Spain & Portugal", body: "Rioja & Ribera del Duero (Tempranillo), Rías Baixas (Albariño), Priorat (Garnacha), Cava (sparkling), Douro (port & dry reds), Vinho Verde."),
            LessonSection(heading: "USA", body: "California: Napa (Cabernet), Sonoma (Chardonnay, Pinot, Zinfandel), Paso Robles (Rhône varieties). Oregon: Willamette Valley Pinot Noir. Washington: Merlot & Syrah. New York: Finger Lakes Riesling."),
            LessonSection(heading: "Southern Hemisphere", body: "Argentina (Malbec in Mendoza), Chile (Carmenère, Cabernet), Australia (Barossa Shiraz, Clare Riesling), New Zealand (Marlborough Sauvignon Blanc), South Africa (Chenin Blanc, Pinotage)."),
        ],
        quiz: [
            QuizQuestion(
                question: "Which grape is Barolo made from?",
                options: ["Sangiovese", "Nebbiolo", "Tempranillo", "Merlot"],
                correctIndex: 1,
                explanation: "Barolo and Barbaresco are 100% Nebbiolo from Piedmont, Italy."
            ),
            QuizQuestion(
                question: "Mendoza, Argentina is best known for which grape?",
                options: ["Malbec", "Syrah", "Pinot Noir", "Riesling"],
                correctIndex: 0,
                explanation: "Malbec, originally from France, found its star home in Argentina's high-altitude vineyards."
            ),
            QuizQuestion(
                question: "Where is Albariño from?",
                options: ["Rías Baixas, Spain", "Piedmont, Italy", "Mosel, Germany", "Barossa, Australia"],
                correctIndex: 0,
                explanation: "Rías Baixas in Galicia, northwest Spain, is Albariño's home."
            ),
        ]
    )
}
