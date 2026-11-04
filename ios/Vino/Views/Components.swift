import SwiftUI

/// Tappable 1–5 star control. Tapping the current rating again clears it.
struct StarRating: View {
    @Binding var rating: Double

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: Double(i) <= rating ? "star.fill" : "star")
                    .foregroundStyle(.yellow)
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
                    .foregroundStyle(Double(i) <= rating ? .yellow : .secondary)
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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label).font(.subheadline)
                Spacer()
                if let detail { Text(detail).font(.caption).foregroundStyle(.secondary) }
            }
            ProgressView(value: min(max(value, 0), 5), total: 5)
        }
        .accessibilityElement(children: .combine)
    }
}

struct GrapeRow: View {
    let grape: Grape

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: grape.style.symbol)
                .foregroundStyle(Theme.burgundy)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(grape.name).font(.headline)
                Text("\(grape.style.rawValue) · \(grape.bodyWord)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
