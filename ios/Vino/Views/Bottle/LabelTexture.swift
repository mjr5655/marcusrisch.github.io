import UIKit

/// The text we print on a generated label.
struct LabelContent: Equatable {
    var producer = ""
    var name = ""
    var grape = ""
    var region = ""
    var country = ""
    var vintage: Int?
    var style: WineStyle = .red

    init(wine: Wine) {
        producer = wine.producer
        name = wine.name
        grape = wine.grape
        region = wine.region
        country = wine.country
        vintage = wine.vintage
        style = wine.style
    }

    init() {}
}

/// Draws the image that gets wrapped around the 3D bottle: your cropped label photo if there is one,
/// otherwise a clean label generated from the wine's details.
enum LabelTexture {
    /// Width / height of the label panel on the bottle.
    static let aspect: CGFloat = 0.8
    static let size = CGSize(width: 1000, height: 1250)

    static func render(content: LabelContent, photo: UIImage?) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            if let photo {
                drawPhoto(photo, in: ctx.cgContext)
            } else {
                drawGenerated(content, in: ctx.cgContext)
            }
        }
    }

    // MARK: Photo

    /// Fits the photo on a background matching its average color, so letterboxing blends in.
    private static func drawPhoto(_ photo: UIImage, in cg: CGContext) {
        let bounds = CGRect(origin: .zero, size: size)
        averageColor(of: photo).setFill()
        cg.fill(bounds)

        let available = bounds.insetBy(dx: 20, dy: 20)
        let scale = min(available.width / photo.size.width, available.height / photo.size.height)
        let drawSize = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
        let origin = CGPoint(x: bounds.midX - drawSize.width / 2, y: bounds.midY - drawSize.height / 2)
        photo.draw(in: CGRect(origin: origin, size: drawSize))
    }

    static func averageColor(of image: UIImage) -> UIColor {
        guard let cgImage = image.cgImage else { return .black }
        var pixel = [UInt8](repeating: 0, count: 4)
        pixel.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return }
            context.interpolationQuality = .medium
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        }
        return UIColor(
            red: CGFloat(pixel[0]) / 255,
            green: CGFloat(pixel[1]) / 255,
            blue: CGFloat(pixel[2]) / 255,
            alpha: 1
        )
    }

    // MARK: Generated label

    private static func drawGenerated(_ c: LabelContent, in cg: CGContext) {
        let bounds = CGRect(origin: .zero, size: size)
        UIColor(red: 0.95, green: 0.91, blue: 0.82, alpha: 1).setFill()
        cg.fill(bounds)

        let gold = UIColor(red: 0.62, green: 0.47, blue: 0.20, alpha: 1)
        let ink = UIColor(red: 0.12, green: 0.10, blue: 0.16, alpha: 1)

        gold.setStroke()
        let outer = UIBezierPath(rect: bounds.insetBy(dx: 34, dy: 34))
        outer.lineWidth = 6
        outer.stroke()
        let inner = UIBezierPath(rect: bounds.insetBy(dx: 52, dy: 52))
        inner.lineWidth = 2
        inner.stroke()

        let left: CGFloat = 120
        let width = size.width - left * 2

        // Producer
        if !c.producer.isEmpty {
            drawText(c.producer.uppercased(), font: { serif($0, .semibold) }, maxSize: 52, minSize: 28,
                     color: ink, kern: 6, in: CGRect(x: left, y: 110, width: width, height: 150))
        }

        // Ornament
        let midX = size.width / 2
        gold.setStroke()
        let line = UIBezierPath()
        line.move(to: CGPoint(x: midX - 140, y: 300)); line.addLine(to: CGPoint(x: midX - 24, y: 300))
        line.move(to: CGPoint(x: midX + 24, y: 300)); line.addLine(to: CGPoint(x: midX + 140, y: 300))
        line.lineWidth = 3
        line.stroke()
        gold.setFill()
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: midX, y: 286)); diamond.addLine(to: CGPoint(x: midX + 14, y: 300))
        diamond.addLine(to: CGPoint(x: midX, y: 314)); diamond.addLine(to: CGPoint(x: midX - 14, y: 300))
        diamond.close()
        diamond.fill()

        // Title: the wine's name, or its grape when there's no name.
        var title = c.name.isEmpty ? c.grape : c.name
        if title.isEmpty && c.producer.isEmpty { title = "Wine" }
        if !title.isEmpty {
            drawText(title, font: { serif($0, .bold) }, maxSize: 120, minSize: 48,
                     color: ink, in: CGRect(x: left, y: 340, width: width, height: 380))
        }

        // Grape (italic) when the title is the name
        if !c.name.isEmpty && !c.grape.isEmpty {
            drawText(c.grape, font: { serifItalic($0) }, maxSize: 58, minSize: 30,
                     color: gold, in: CGRect(x: left, y: 735, width: width, height: 90))
        }

        // Vintage
        if let vintage = c.vintage {
            drawText(String(vintage), font: { serif($0, .semibold) }, maxSize: 130, minSize: 60,
                     color: gold, kern: 4, in: CGRect(x: left, y: 860, width: width, height: 150))
        }

        // Region · Country
        let origin = [c.region, c.country].filter { !$0.isEmpty }.joined(separator: " · ")
        if !origin.isEmpty {
            drawText(origin.uppercased(), font: { serif($0, .medium) }, maxSize: 44, minSize: 24,
                     color: ink, kern: 4, in: CGRect(x: left, y: 1050, width: width, height: 110))
        }
    }

    // MARK: Text helpers

    private static func serif(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
        Theme.uiSerif(size: size, weight: weight)
    }

    private static func serifItalic(_ size: CGFloat) -> UIFont {
        let base = Theme.uiSerif(size: size, weight: .regular)
        if let descriptor = base.fontDescriptor.withSymbolicTraits(.traitItalic) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return base
    }

    /// Draws centered, wrapped text shrunk until it fits `rect`, vertically centered in it.
    private static func drawText(
        _ text: String,
        font: (CGFloat) -> UIFont,
        maxSize: CGFloat,
        minSize: CGFloat,
        color: UIColor,
        kern: CGFloat = 0,
        in rect: CGRect
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineBreakMode = .byWordWrapping

        var fontSize = maxSize
        var attributes: [NSAttributedString.Key: Any] = [:]
        var textBounds = CGRect.zero
        while true {
            attributes = [
                .font: font(fontSize),
                .foregroundColor: color,
                .paragraphStyle: paragraph,
                .kern: kern,
            ]
            textBounds = (text as NSString).boundingRect(
                with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: attributes,
                context: nil
            )
            if textBounds.height <= rect.height || fontSize <= minSize { break }
            fontSize -= 4
        }

        let height = min(textBounds.height, rect.height)
        let drawRect = CGRect(x: rect.minX, y: rect.minY + (rect.height - height) / 2, width: rect.width, height: height)
        (text as NSString).draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
    }
}
