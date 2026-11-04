import SwiftUI
import SwiftData

/// Wallet-style detail page: a 3D bottle fills the top half, everything we know about the wine sits below.
struct BottleDetailView: View {
    @Bindable var wine: Wine
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var labelImage: UIImage?
    @State private var showingEdit = false
    @State private var confirmDelete = false

    private var shape: BottleShape {
        BottleGeometry.shape(for: wine.style, grape: wine.catalogGrape)
    }

    /// Changes whenever something printed on the label changes, so we re-render the texture.
    private var labelSignature: String {
        [
            wine.name, wine.producer, wine.grape, wine.region, wine.country, wine.styleRaw,
            String(wine.vintage ?? 0), String(wine.labelCropData?.count ?? 0),
        ].joined(separator: "|")
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                bottleCard
                    .frame(height: geo.size.height * 0.5)
                ScrollView {
                    details
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
            }
        }
        .background(Theme.navy.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showingEdit = true } label: { Label("Edit details", systemImage: "pencil") }
                    Button {
                        wine.isWishlist.toggle()
                    } label: {
                        Label(wine.isWishlist ? "Mark as tasted" : "Move to wishlist",
                              systemImage: wine.isWishlist ? "checkmark.circle" : "heart")
                    }
                    Button(role: .destructive) { confirmDelete = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More")
            }
        }
        .task(id: labelSignature) {
            let photo = wine.labelCropData.flatMap { UIImage(data: $0) }
            labelImage = LabelTexture.render(content: LabelContent(wine: wine), photo: photo)
        }
        .sheet(isPresented: $showingEdit) {
            NavigationStack {
                Form { WineForm(wine: wine) }
                    .vinoScreen()
                    .navigationTitle("Edit Wine")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { showingEdit = false }
                        }
                    }
            }
        }
        .confirmationDialog("Delete this wine?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                context.delete(wine)
                dismiss()
            }
        }
    }

    // MARK: 3D card

    private var bottleCard: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(LinearGradient(colors: [Theme.surfaceHigh, Theme.surface], startPoint: .top, endPoint: .bottom))
                .overlay(
                    RadialGradient(
                        colors: [Theme.gold.opacity(0.22), .clear],
                        center: UnitPoint(x: 0.5, y: 0.5),
                        startRadius: 10,
                        endRadius: 220
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                )
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).strokeBorder(Theme.hairline))

            BottleSceneView(shape: shape, style: wine.style, labelImage: labelImage)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .accessibilityLabel("3D model of \(wine.displayName). Drag to rotate, double tap to zoom on the label.")

            Label("Drag to spin · double-tap to zoom", systemImage: "hand.draw")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    // MARK: Details

    @ViewBuilder
    private var details: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                InfoTile(title: "Grape", value: wine.grape)
                InfoTile(title: "Vintage", value: wine.vintage.map { String($0) } ?? "")
                InfoTile(title: "Region", value: wine.region)
                InfoTile(title: "Country", value: wine.country)
                InfoTile(title: "Price", value: priceText)
                if wine.isWishlist {
                    InfoTile(title: "Status", value: "Wishlist")
                } else {
                    InfoTile(title: "Tasted by", value: wine.taster.isEmpty ? "Both of us" : wine.taster)
                }
            }

            if !wine.notes.isEmpty {
                InfoCard(title: "Tasting notes") {
                    Text(wine.notes).lineSpacing(3)
                }
            }

            if let grape = wine.catalogGrape {
                grapeCard(grape)
            }

            InfoCard(title: "Added") {
                Text(wine.dateAdded.formatted(date: .long, time: .omitted))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(wine.displayName)
                .font(.serif(.title, weight: .bold))
                .foregroundStyle(Theme.cream)
            if !wine.subtitle.isEmpty {
                Text(wine.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                StyleChip(style: wine.style)
                if wine.isWishlist {
                    Button { wine.isWishlist = false } label: {
                        Label("Mark as tasted", systemImage: "checkmark")
                    }
                    .buttonStyle(GoldButtonStyle())
                } else {
                    StarRating(rating: $wine.rating)
                }
            }
        }
    }

    private func grapeCard(_ grape: Grape) -> some View {
        InfoCard(title: "About \(grape.name)") {
            VStack(alignment: .leading, spacing: 14) {
                Text(grape.summary).lineSpacing(3)
                MeterRow(label: "Body", value: Double(grape.body), detail: grape.bodyWord)
                MeterRow(label: "Acidity", value: Double(grape.acidity), detail: grape.acidityWord)
                if grape.style == .red {
                    MeterRow(label: "Tannin", value: Double(grape.tannin), detail: grape.tanninWord)
                }
                MeterRow(label: "Sweetness", value: Double(grape.sweetness), detail: grape.sweetnessWord)
                labeled("Typical flavors", grape.flavors.joined(separator: " · "))
                labeled("Pairs with", grape.pairings.joined(separator: " · "))
                NavigationLink {
                    GrapeDetailView(grape: grape)
                } label: {
                    HStack {
                        Text("Open grape guide")
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.gold)
                }
            }
        }
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text(value).font(.subheadline)
        }
    }

    private var priceText: String {
        guard let price = wine.price else { return "" }
        return price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
}

// MARK: - Pieces

struct InfoTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(0.8)
                .foregroundStyle(.secondary)
            Text(value.isEmpty ? "—" : value)
                .font(.serif(.headline))
                .foregroundStyle(value.isEmpty ? Color.secondary : Theme.cream)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.hairline))
        .accessibilityElement(children: .combine)
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.serif(.title3))
                .foregroundStyle(Theme.goldSoft)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.hairline))
    }
}
