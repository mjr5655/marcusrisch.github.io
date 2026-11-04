import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Wine.dateAdded, order: .reverse) private var wines: [Wine]

    @State private var showWishlist = false
    @State private var search = ""
    @State private var showingAdd = false
    @State private var showingSettings = false

    private var filtered: [Wine] {
        wines
            .filter { $0.isWishlist == showWishlist }
            .filter { wine in
                search.isEmpty || [wine.name, wine.producer, wine.grape, wine.region, wine.country]
                    .contains { $0.localizedCaseInsensitiveContains(search) }
            }
    }

    private var triedCount: Int { wines.filter { !$0.isWishlist }.count }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("List", selection: $showWishlist) {
                    Text("Tasted").tag(false)
                    Text("Wishlist").tag(true)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])
                .padding(.bottom, 8)

                if filtered.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filtered) { wine in
                            NavigationLink(value: wine) { WineRow(wine: wine) }
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Theme.surface)
                                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.hairline))
                                        .padding(.vertical, 4)
                                )
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.navy.ignoresSafeArea())
            .navigationTitle("Cellar Journal")
            .navigationDestination(for: Wine.self) { BottleDetailView(wine: $0) }
            .searchable(text: $search, prompt: "Search wines")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: { Image(systemName: "person.2") }
                        .accessibilityLabel("Names")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus.circle.fill") }
                        .accessibilityLabel("Add wine")
                }
            }
            .sheet(isPresented: $showingAdd) { AddWineView(startOnWishlist: showWishlist) }
            .sheet(isPresented: $showingSettings) { NamesView() }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: showWishlist ? "heart.text.square" : "wineglass")
                .font(.system(size: 52))
                .foregroundStyle(Theme.gold)
            Text(search.isEmpty
                 ? (showWishlist ? "Nothing on the wishlist" : "Your cellar journal is empty")
                 : "No matches")
                .font(.serif(.title3))
            Text(search.isEmpty
                 ? "Tap + to add a bottle, or scan a label."
                 : "Nothing matches \"\(search)\".")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if search.isEmpty {
                Button { showingAdd = true } label: { Label("Add a wine", systemImage: "plus") }
                    .buttonStyle(GoldButtonStyle())
                    .padding(.top, 4)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func delete(at offsets: IndexSet) {
        let items = filtered
        for index in offsets { context.delete(items[index]) }
    }
}

struct WineRow: View {
    let wine: Wine

    var body: some View {
        HStack(spacing: 14) {
            LabelThumbnail(wine: wine)
            VStack(alignment: .leading, spacing: 4) {
                Text(wine.displayName)
                    .font(.serif(.headline))
                    .foregroundStyle(Theme.cream)
                    .lineLimit(2)
                if !wine.subtitle.isEmpty {
                    Text(wine.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                HStack(spacing: 8) {
                    StyleChip(style: wine.style)
                    if !wine.isWishlist { StarsDisplay(rating: wine.rating) }
                }
                if !wine.taster.isEmpty {
                    Text(wine.taster).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
