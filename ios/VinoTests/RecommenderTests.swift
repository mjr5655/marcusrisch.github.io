import XCTest
@testable import Vino

final class RecommenderTests: XCTestCase {
    func testNoRatingsReturnsStarterWines() {
        let recs = Recommender.recommend(from: [])
        XCTAssertFalse(recs.isEmpty)
        XCTAssertTrue(recs.contains { $0.grape.name == "Pinot Noir" })
    }

    func testProfileIsNilWithoutLikedWines() {
        let tastings = [TastedWine(grape: "Merlot", rating: 2)]
        XCTAssertNil(Recommender.profile(from: tastings))
    }

    func testProfileAveragesLikedGrapes() throws {
        let tastings = [
            TastedWine(grape: "Cabernet Sauvignon", rating: 5),
            TastedWine(grape: "Malbec", rating: 5),
        ]
        let profile = try XCTUnwrap(Recommender.profile(from: tastings))
        XCTAssertEqual(profile.body, 4.5, accuracy: 0.01)
        XCTAssertGreaterThan(profile.tannin, 4)
    }

    func testRecommendsSimilarGrapeAndSkipsTriedOnes() {
        let tastings = [TastedWine(grape: "Cabernet Sauvignon", rating: 5)]
        let recs = Recommender.recommend(from: tastings, limit: 3)
        XCTAssertFalse(recs.contains { $0.grape.name == "Cabernet Sauvignon" })
        // A big, tannic red should rank above a sweet, light white.
        XCTAssertTrue(recs.contains { ["Syrah", "Malbec", "Nebbiolo", "Tempranillo"].contains($0.grape.name) })
    }

    func testDislikedGrapeIsNotRecommendedBack() {
        let tastings = [
            TastedWine(grape: "Pinot Noir", rating: 5),
            TastedWine(grape: "Merlot", rating: 1),
        ]
        let recs = Recommender.recommend(from: tastings, limit: 20)
        XCTAssertFalse(recs.contains { $0.grape.name == "Merlot" })
    }

    func testFoodPairingFindsSteakWines() {
        let grapes = Recommender.grapes(forFood: "grilled steak")
        XCTAssertTrue(grapes.contains { $0.name == "Cabernet Sauvignon" })
    }

    func testCatalogMatchHandlesAliases() {
        XCTAssertEqual(GrapeCatalog.match("Shiraz")?.name, "Syrah")
        XCTAssertEqual(GrapeCatalog.match("pinot gris")?.name, "Pinot Grigio")
        XCTAssertNil(GrapeCatalog.match(""))
    }

    func testEveryLessonQuestionHasValidAnswerIndex() {
        for q in LessonLibrary.allQuestions {
            XCTAssertTrue(q.options.indices.contains(q.correctIndex), q.question)
        }
    }
}
