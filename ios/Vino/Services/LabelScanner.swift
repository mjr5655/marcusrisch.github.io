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
                    return RecognizedLine(text: text, height: Double(obs.boundingBox.height))
                }
        }.value
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
