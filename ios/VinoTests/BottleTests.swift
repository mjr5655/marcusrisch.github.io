import XCTest
import UIKit
@testable import Vino

final class BottleTests: XCTestCase {
    func testEveryShapeProfileIsWellFormed() {
        for shape in BottleGeometry.all {
            XCTAssertEqual(shape.profile.first, CGPoint(x: 0, y: 0), shape.name)
            XCTAssertEqual(shape.profile.last?.x, 0, shape.name)
            XCTAssertTrue(shape.profile.allSatisfy { $0.x >= 0 }, shape.name)
            // The label must sit on the straight part of the body, below the foil.
            XCTAssertGreaterThan(shape.labelBottom, 0.1, shape.name)
            XCTAssertLessThan(shape.labelTop, shape.foilStart, shape.name)
            // A flat label has to fit within the visible front half of the bottle.
            XCTAssertLessThan(shape.labelWidth / shape.bodyRadius, .pi, shape.name)
        }
    }

    func testSmoothingKeepsEndpointsAndNeverGoesNegative() {
        for shape in BottleGeometry.all {
            let smooth = BottleGeometry.smooth(shape.profile)
            XCTAssertGreaterThan(smooth.count, shape.profile.count)
            XCTAssertEqual(smooth.first, shape.profile.first)
            XCTAssertEqual(smooth.last, shape.profile.last)
            XCTAssertTrue(smooth.allSatisfy { $0.x >= 0 })
        }
    }

    func testShapeSelection() {
        XCTAssertEqual(BottleGeometry.shape(for: .sparkling, grape: nil).name, "champagne")
        XCTAssertEqual(BottleGeometry.shape(for: .red, grape: GrapeCatalog.match("Pinot Noir")).name, "burgundy")
        XCTAssertEqual(BottleGeometry.shape(for: .white, grape: GrapeCatalog.match("Riesling")).name, "hock")
        XCTAssertEqual(BottleGeometry.shape(for: .red, grape: GrapeCatalog.match("Cabernet Sauvignon")).name, "bordeaux")
    }

    func testLatheBuildsGeometry() {
        let geometry = BottleGeometry.lathe(profile: BottleGeometry.smooth(BottleGeometry.bordeaux.profile), segments: 16)
        XCTAssertEqual(geometry.elements.count, 1)
        XCTAssertFalse(geometry.sources.isEmpty)
    }

    func testGeneratedLabelHasExpectedSize() {
        var content = LabelContent()
        content.producer = "Caymus Vineyards"
        content.name = "Special Selection"
        content.grape = "Cabernet Sauvignon"
        content.vintage = 2021
        let image = LabelTexture.render(content: content, photo: nil)
        XCTAssertEqual(image.size, LabelTexture.size)
    }

    func testLabelCropUsesTextBoundsAndFlipsVisionCoordinates() throws {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 400))
        let photo = renderer.image { ctx in
            UIColor.gray.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 400))
        }
        // Text covering the middle of the photo (Vision coordinates are bottom-left origin).
        let lines = [
            RecognizedLine(text: "A", height: 0.1, box: CGRect(x: 0.2, y: 0.4, width: 0.6, height: 0.1)),
            RecognizedLine(text: "B", height: 0.1, box: CGRect(x: 0.25, y: 0.55, width: 0.5, height: 0.1)),
        ]
        let crop = try XCTUnwrap(LabelScanner.labelCrop(from: photo, lines: lines))
        XCTAssertLessThan(crop.size.width, photo.size.width)
        XCTAssertLessThan(crop.size.height, photo.size.height)
    }

    func testLabelCropReturnsNilWithoutText() {
        let photo = UIGraphicsImageRenderer(size: CGSize(width: 50, height: 50)).image { _ in }
        XCTAssertNil(LabelScanner.labelCrop(from: photo, lines: []))
    }

    func testAverageColorOfSolidImage() {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { ctx in
            UIColor(red: 1, green: 0, blue: 0, alpha: 1).setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        LabelTexture.averageColor(of: image).getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertGreaterThan(r, 0.9)
        XCTAssertLessThan(g, 0.1)
    }
}
