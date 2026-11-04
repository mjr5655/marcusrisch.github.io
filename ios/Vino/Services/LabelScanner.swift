import UIKit
import Vision

/// On-device text recognition for wine label photos. Nothing leaves the phone.
enum LabelScanner {
    /// Reads text from the image, ordered top to bottom.
    static func recognize(_ image: UIImage) async throws -> [RecognizedLine] {
        guard let cgImage = image.cgImage else { return [] }
        return try await Task.detached(priority: .userInitiated) { () throws -> [RecognizedLine] in
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            // Brand names aren't dictionary words, so autocorrect would mangle them.
            request.usesLanguageCorrection = false
            try VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])

            let observations = request.results ?? []
            return observations
                .sorted { $0.boundingBox.midY > $1.boundingBox.midY } // Vision's origin is bottom-left
                .compactMap { obs -> RecognizedLine? in
                    guard let text = obs.topCandidates(1).first?.string else { return nil }
                    return RecognizedLine(text: text, height: Double(obs.boundingBox.height), box: obs.boundingBox)
                }
        }.value
    }
}

extension LabelScanner {
    /// Crops the photo to the area covered by the recognized text, with some padding.
    /// Returns nil when no text was found or the region is implausibly small.
    static func labelCrop(from image: UIImage, lines: [RecognizedLine]) -> UIImage? {
        let boxes = lines.map(\.box).filter { $0.width > 0 && $0.height > 0 }
        guard let first = boxes.first, let cgImage = image.cgImage else { return nil }
        var union = first
        for box in boxes.dropFirst() { union = union.union(box) }
        union = union.insetBy(dx: -0.05, dy: -0.05).intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
        guard union.width * union.height > 0.08 else { return nil }

        let w = CGFloat(cgImage.width), h = CGFloat(cgImage.height)
        // Vision's origin is bottom-left; image pixels are top-left.
        let rect = CGRect(
            x: union.minX * w,
            y: (1 - union.maxY) * h,
            width: union.width * w,
            height: union.height * h
        ).integral
        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cropped)
    }
}

extension UIImage {
    /// Redraws the image upright and scaled so its longest side is at most `maxDimension` points.
    /// This bakes in EXIF orientation (so OCR sees upright text) and keeps stored photos small.
    func normalized(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        let scale = longest > maxDimension ? maxDimension / longest : 1
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
