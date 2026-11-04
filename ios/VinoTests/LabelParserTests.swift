import XCTest
@testable import Vino

final class LabelParserTests: XCTestCase {
    private func lines(_ items: [(String, Double)]) -> [RecognizedLine] {
        items.map { RecognizedLine(text: $0.0, height: $0.1) }
    }

    func testCaliforniaCabernetLabel() {
        let scanned = LabelParser.parse(lines([
            ("CAYMUS VINEYARDS", 0.06),
            ("NAPA VALLEY", 0.03),
            ("2021", 0.03),
            ("Cabernet Sauvignon", 0.04),
            ("ALC. 14.5% BY VOL.", 0.01),
            ("750 ML", 0.01),
            ("GOVERNMENT WARNING: According to the Surgeon General", 0.01),
        ]), currentYear: 2026)

        XCTAssertEqual(scanned.producer, "Caymus Vineyards")
        XCTAssertEqual(scanned.grape, "Cabernet Sauvignon")
        XCTAssertEqual(scanned.vintage, 2021)
        XCTAssertEqual(scanned.region, "Napa Valley")
        XCTAssertEqual(scanned.country, "USA")
        XCTAssertEqual(scanned.style, .red)
    }

    func testFrenchLabelWithAccentsAndAppellation() {
        let scanned = LabelParser.parse(lines([
            ("Château de Beaucastel", 0.06),
            ("CHÂTEAUNEUF-DU-PAPE", 0.04),
            ("Appellation Châteauneuf-du-Pape Contrôlée", 0.02),
            ("2019", 0.03),
            ("Product of France", 0.015),
            ("13.5% alc/vol", 0.01),
        ]), currentYear: 2026)

        XCTAssertTrue(scanned.producer.contains("Beaucastel"))
        XCTAssertEqual(scanned.region, "Châteauneuf-du-Pape")
        XCTAssertEqual(scanned.country, "France")
        XCTAssertEqual(scanned.vintage, 2019)
        XCTAssertEqual(scanned.grape, "Grenache")
    }

    func testFoundingYearIsNotTheVintage() {
        let scanned = LabelParser.parse(lines([
            ("Estate Winery", 0.05), ("Est. 1985", 0.02), ("2018", 0.03), ("Pinot Noir", 0.04),
        ]), currentYear: 2026)
        XCTAssertEqual(scanned.vintage, 2018)
    }

    func testRoseKeywordOverridesRedGrape() {
        let scanned = LabelParser.parse(lines([
            ("Maison Example", 0.05), ("Syrah Rosé", 0.04), ("2024", 0.03),
        ]), currentYear: 2026)
        XCTAssertEqual(scanned.style, .rose)
    }

    func testEmptyInputGivesEmptyResult() {
        XCTAssertTrue(LabelParser.parse([]).isEmpty)
        XCTAssertTrue(LabelParser.parse(lines([("", 0.1), ("  ", 0.1)])).isEmpty)
    }

    func testFillEmptyFieldsDoesNotOverwriteTypedValues() {
        let wine = Wine(name: "My Pick", grape: "")
        ScannedWine(name: "Scanned Name", producer: "Scanned Producer", grape: "Malbec", vintage: 2020)
            .fillEmptyFields(of: wine)
        XCTAssertEqual(wine.name, "My Pick")
        XCTAssertEqual(wine.producer, "Scanned Producer")
        XCTAssertEqual(wine.grape, "Malbec")
        XCTAssertEqual(wine.vintage, 2020)
    }
}
