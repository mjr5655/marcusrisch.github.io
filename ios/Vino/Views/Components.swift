import SwiftUI
import UIKit

/// Tappable 1–5 star control. Tapping the current rating again clears it.
struct StarRating: View {
    @Binding var rating: Double

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: Double(i) <= rating ? "star.fill" : "star")
                    .foregroundStyle(Theme.gold)
                    .font(.title3)
                    .onTapGesture {
                        rating = (rating == Double(i)) ? 0 : Double(i)
                    }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue(rating == 0 ? "Not rated" : "\(Int(rating)) of 5 stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(5, rating + 1)
            case .decrement: rating = max(0, rating - 1)
            @unknown default: break
            }
        }
    }
}

/// Read-only compact star display.
struct StarsDisplay: View {
    let rating: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: Double(i) <= rating ? "star.fill" : "star")
                    .font(.caption2)
                    .foregroundStyle(Double(i) <= rating ? Theme.gold : Theme.gold.opacity(0.25))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rating == 0 ? "Not rated" : "\(Int(rating)) of 5 stars")
    }
}

/// A labeled 1–5 meter used for body / acidity / tannin / sweetness.
struct MeterRow: View {
    let label: String
    let value: Double
    var detail: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                if let detail { Text(detail).font(.caption).foregroundStyle(.secondary) }
            }
            ProgressView(value: min(max(value, 0), 5), total: 5)
                .tint(Theme.gold)
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

/// Round icon badge tinted by wine style.
struct StyleBadge: View {
    let style: WineStyle
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: style.symbol)
            .font(.system(size: size * 0.42))
            .foregroundStyle(style.color)
            .frame(width: size, height: size)
            .background(style.color.opacity(0.15), in: Circle())
            .accessibilityHidden(true)
    }
}

struct GrapeRow: View {
    let grape: Grape

    var body: some View {
        HStack(spacing: 12) {
            StyleBadge(style: grape.style, size: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(grape.name).font(.serif(.headline))
                Text("\(grape.style.rawValue) · \(grape.bodyWord)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Small decoded label photo with a placeholder badge when there isn't one.
struct LabelThumbnail: View {
    let wine: Wine
    var width: CGFloat = 52
    var height: CGFloat = 70

    var body: some View {
        Group {
            if let data = wine.labelImageData,
               let image = UIImage(data: data)?.preparingThumbnail(of: CGSize(width: width * 3, height: height * 3)) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    wine.style.color.opacity(0.12)
                    Image(systemName: wine.style.symbol)
                        .font(.title3)
                        .foregroundStyle(wine.style.color)
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.hairline))
        .accessibilityHidden(true)
    }
}

/// Section title in the serif display face, used above custom cards.
struct SerifHeader: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.serif(.title3))
            .foregroundStyle(Theme.goldSoft)
            .textCase(nil)
    }
}
