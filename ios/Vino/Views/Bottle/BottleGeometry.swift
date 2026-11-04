import SceneKit
import UIKit

/// A bottle silhouette: a profile (radius, height) that gets revolved around the vertical axis.
struct BottleShape {
    let name: String
    /// Control points (radius, y) from the bottom center up to the top center.
    let profile: [CGPoint]
    let bodyRadius: CGFloat
    /// Vertical range of the straight part of the body where the label sits.
    let labelBottom: CGFloat
    let labelTop: CGFloat
    /// Height above which the foil capsule covers the neck.
    let foilStart: CGFloat

    var labelHeight: CGFloat { labelTop - labelBottom }
    var labelWidth: CGFloat { labelHeight * LabelTexture.aspect }
    var labelCenterY: CGFloat { (labelTop + labelBottom) / 2 }
}

enum BottleGeometry {
    /// If a label ever appears upside-down or mirrored vertically, flip this.
    static let flipV = false

    // MARK: Shapes

    private static func p(_ r: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: r, y: y) }

    static let bordeaux = BottleShape(
        name: "bordeaux",
        profile: [
            p(0, 0), p(0.28, 0), p(0.36, 0.02), p(0.38, 0.10), p(0.38, 1.70), p(0.37, 1.82),
            p(0.30, 2.00), p(0.20, 2.14), p(0.15, 2.28), p(0.145, 2.55), p(0.15, 2.86),
            p(0.17, 2.92), p(0.17, 3.16), p(0.15, 3.18), p(0, 3.18),
        ],
        bodyRadius: 0.38, labelBottom: 0.30, labelTop: 1.55, foilStart: 2.78
    )

    static let burgundy = BottleShape(
        name: "burgundy",
        profile: [
            p(0, 0), p(0.30, 0), p(0.38, 0.02), p(0.40, 0.10), p(0.40, 1.30), p(0.385, 1.55),
            p(0.33, 1.85), p(0.25, 2.12), p(0.18, 2.35), p(0.15, 2.55), p(0.147, 2.86),
            p(0.165, 2.92), p(0.165, 3.12), p(0.145, 3.14), p(0, 3.14),
        ],
        bodyRadius: 0.40, labelBottom: 0.28, labelTop: 1.24, foilStart: 2.76
    )

    static let champagne = BottleShape(
        name: "champagne",
        profile: [
            p(0, 0), p(0.34, 0), p(0.42, 0.03), p(0.44, 0.12), p(0.44, 1.25), p(0.42, 1.55),
            p(0.35, 1.90), p(0.26, 2.20), p(0.19, 2.40), p(0.165, 2.60), p(0.165, 2.92),
            p(0.205, 2.99), p(0.205, 3.12), p(0.185, 3.14), p(0, 3.14),
        ],
        bodyRadius: 0.44, labelBottom: 0.30, labelTop: 1.35, foilStart: 2.45
    )

    static let hock = BottleShape(
        name: "hock",
        profile: [
            p(0, 0), p(0.25, 0), p(0.32, 0.02), p(0.34, 0.10), p(0.34, 1.55), p(0.325, 1.80),
            p(0.27, 2.10), p(0.19, 2.40), p(0.14, 2.60), p(0.135, 3.00), p(0.15, 3.05),
            p(0.15, 3.28), p(0.13, 3.30), p(0, 3.30),
        ],
        bodyRadius: 0.34, labelBottom: 0.30, labelTop: 1.45, foilStart: 2.90
    )

    static let all: [BottleShape] = [bordeaux, burgundy, champagne, hock]

    /// Picks a bottle silhouette from the wine's style and grape.
    static func shape(for style: WineStyle, grape: Grape?) -> BottleShape {
        if style == .sparkling { return champagne }
        switch grape?.name {
        case "Pinot Noir", "Chardonnay", "Nebbiolo", "Grenache": return burgundy
        case "Riesling", "Gewürztraminer", "Moscato": return hock
        default: return bordeaux
        }
    }

    // MARK: Colors

    static func glassColor(for style: WineStyle) -> UIColor {
        switch style {
        case .red: return UIColor(red: 0.04, green: 0.10, blue: 0.06, alpha: 1)
        case .white: return UIColor(red: 0.38, green: 0.55, blue: 0.34, alpha: 1)
        case .rose: return UIColor(red: 0.86, green: 0.62, blue: 0.66, alpha: 1)
        case .sparkling: return UIColor(red: 0.06, green: 0.13, blue: 0.07, alpha: 1)
        case .dessert: return UIColor(red: 0.50, green: 0.30, blue: 0.09, alpha: 1)
        case .orange: return UIColor(red: 0.42, green: 0.27, blue: 0.10, alpha: 1)
        }
    }

    static func foilColor(for style: WineStyle) -> UIColor {
        switch style {
        case .red: return UIColor(red: 0.42, green: 0.07, blue: 0.14, alpha: 1)
        case .white, .sparkling, .dessert: return UIColor(red: 0.83, green: 0.69, blue: 0.34, alpha: 1)
        case .rose, .orange: return UIColor(red: 0.72, green: 0.45, blue: 0.32, alpha: 1)
        }
    }

    // MARK: Profile smoothing

    /// Catmull-Rom smoothing so the shoulders look curved instead of faceted.
    static func smooth(_ points: [CGPoint], samples: Int = 10) -> [CGPoint] {
        guard points.count > 2 else { return points }
        var out: [CGPoint] = []
        for i in 0..<(points.count - 1) {
            let p0 = points[max(i - 1, 0)]
            let p1 = points[i]
            let p2 = points[i + 1]
            let p3 = points[min(i + 2, points.count - 1)]
            for s in 0..<samples {
                let t = CGFloat(s) / CGFloat(samples)
                let t2 = t * t
                let t3 = t2 * t
                func cr(_ a: CGFloat, _ b: CGFloat, _ c: CGFloat, _ d: CGFloat) -> CGFloat {
                    0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t2 + (-a + 3 * b - 3 * c + d) * t3)
                }
                out.append(CGPoint(x: max(0, cr(p0.x, p1.x, p2.x, p3.x)), y: cr(p0.y, p1.y, p2.y, p3.y)))
            }
        }
        if let last = points.last { out.append(last) }
        return out
    }

    // MARK: Geometry

    /// Revolves a (radius, y) profile around the Y axis.
    static func lathe(profile: [CGPoint], segments: Int = 72) -> SCNGeometry {
        let count = profile.count
        var vertices: [SCNVector3] = []
        var normals: [SCNVector3] = []
        vertices.reserveCapacity(count * (segments + 1))
        normals.reserveCapacity(count * (segments + 1))

        for i in 0..<count {
            let point = profile[i]
            let prev = profile[max(i - 1, 0)]
            let next = profile[min(i + 1, count - 1)]
            var dr = next.x - prev.x
            var dy = next.y - prev.y
            let length = max(hypot(dr, dy), 1e-6)
            dr /= length
            dy /= length
            // Outward normal in the (r, y) plane is the tangent rotated by -90°.
            let nr = dy
            let ny = -dr
            for j in 0...segments {
                let theta = 2 * CGFloat.pi * CGFloat(j) / CGFloat(segments)
                let c = cos(theta), s = sin(theta)
                vertices.append(SCNVector3(Float(point.x * c), Float(point.y), Float(point.x * s)))
                normals.append(SCNVector3(Float(nr * c), Float(ny), Float(nr * s)))
            }
        }

        var indices: [UInt32] = []
        let row = segments + 1
        for i in 0..<(count - 1) {
            for j in 0..<segments {
                // Higher theta is to the viewer's left, so this order is counter-clockwise from outside.
                let bl = UInt32(i * row + j + 1)
                let br = UInt32(i * row + j)
                let tr = UInt32((i + 1) * row + j)
                let tl = UInt32((i + 1) * row + j + 1)
                indices += [bl, br, tr, bl, tr, tl]
            }
        }

        return SCNGeometry(
            sources: [SCNGeometrySource(vertices: vertices), SCNGeometrySource(normals: normals)],
            elements: [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
        )
    }

    /// A curved label panel that wraps the front of the bottle (facing +Z, toward the camera).
    static func labelPatch(radius: CGFloat, y0: CGFloat, y1: CGFloat, width: CGFloat, columns: Int = 48) -> SCNGeometry {
        let arc = width / radius
        let thetaMax = CGFloat.pi / 2 + arc / 2
        var vertices: [SCNVector3] = []
        var normals: [SCNVector3] = []
        var uvs: [CGPoint] = []

        for row in 0...1 {
            let y = row == 0 ? y0 : y1
            for c in 0...columns {
                let f = CGFloat(c) / CGFloat(columns)
                let theta = thetaMax - arc * f // left → right as seen by the camera
                let cx = cos(theta), sz = sin(theta)
                vertices.append(SCNVector3(Float(radius * cx), Float(y), Float(radius * sz)))
                normals.append(SCNVector3(Float(cx), 0, Float(sz)))
                let v: CGFloat = flipV ? CGFloat(row) : 1 - CGFloat(row)
                uvs.append(CGPoint(x: f, y: v))
            }
        }

        var indices: [UInt32] = []
        let stride = columns + 1
        for c in 0..<columns {
            let bl = UInt32(c), br = UInt32(c + 1)
            let tl = UInt32(stride + c), tr = UInt32(stride + c + 1)
            indices += [bl, br, tr, bl, tr, tl]
        }

        return SCNGeometry(
            sources: [
                SCNGeometrySource(vertices: vertices),
                SCNGeometrySource(normals: normals),
                SCNGeometrySource(textureCoordinates: uvs),
            ],
            elements: [SCNGeometryElement(indices: indices, primitiveType: .triangles)]
        )
    }

    /// The glass body plus the foil capsule, as one node.
    static func makeBottleNode(shape: BottleShape, style: WineStyle) -> (node: SCNNode, label: SCNNode, labelMaterial: SCNMaterial) {
        let smoothed = smooth(shape.profile)

        let glass = lathe(profile: smoothed)
        let glassMaterial = SCNMaterial()
        glassMaterial.lightingModel = .physicallyBased
        glassMaterial.diffuse.contents = glassColor(for: style)
        glassMaterial.metalness.contents = 0.05
        glassMaterial.roughness.contents = 0.10
        glassMaterial.isDoubleSided = true
        glass.materials = [glassMaterial]

        // Foil: the upper part of the profile, nudged outward.
        let foilStartIndex = smoothed.firstIndex { $0.y >= shape.foilStart } ?? smoothed.count - 2
        let foilProfile = smoothed[foilStartIndex...].map { point in
            CGPoint(x: point.x > 0.001 ? point.x + 0.012 : 0, y: point.y)
        }
        let foil = lathe(profile: Array(foilProfile), segments: 48)
        let foilMaterial = SCNMaterial()
        foilMaterial.lightingModel = .physicallyBased
        foilMaterial.diffuse.contents = foilColor(for: style)
        foilMaterial.metalness.contents = 0.85
        foilMaterial.roughness.contents = 0.32
        foilMaterial.isDoubleSided = true
        foil.materials = [foilMaterial]

        let label = labelPatch(
            radius: shape.bodyRadius + 0.01,
            y0: shape.labelBottom,
            y1: shape.labelTop,
            width: shape.labelWidth
        )
        let labelMaterial = SCNMaterial()
        labelMaterial.lightingModel = .blinn
        labelMaterial.specular.contents = UIColor(white: 0.15, alpha: 1)
        labelMaterial.shininess = 0.15
        labelMaterial.isDoubleSided = true
        labelMaterial.diffuse.mipFilter = .linear
        labelMaterial.diffuse.minificationFilter = .linear
        labelMaterial.diffuse.magnificationFilter = .linear
        labelMaterial.diffuse.maxAnisotropy = 8
        label.materials = [labelMaterial]

        let node = SCNNode()
        node.addChildNode(SCNNode(geometry: glass))
        node.addChildNode(SCNNode(geometry: foil))
        let labelNode = SCNNode(geometry: label)
        node.addChildNode(labelNode)
        return (node, labelNode, labelMaterial)
    }
}
