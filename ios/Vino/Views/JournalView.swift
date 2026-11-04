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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("List", selection: $showWishlist) {
                    Text("Tasted").tag(false)
                    Text("Wishlist").tag(true)
                }
                .pickerStyle(.segmented)
                .padding([.horizontal, .top])

                if filtered.isEmpty {
                    ContentUnavailableView(
                        showWishlist ? "No wishlist wines" : "No wines yet",
                        systemImage: "wineglass",
                        description: Text(search.isEmpty
                            ? "Tap + to add a bottle."
                            : "Nothing matches \"\(search)\".")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filtered) { wine in
                            NavigationLink(value: wine) { WineRow(wine: wine) }
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Journal")
            .navigationDestination(for: Wine.self) { WineDetailView(wine: $0) }
            .searchable(text: $search, prompt: "Search wines")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showingSettings = true } label: { Image(systemName: "person.2") }
                        .accessibilityLabel("Names")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingAdd = true } label: { Image(systemName: "plus") }
                        .accessibilityLabel("Add wine")
                }
            }
            .sheet(isPresented: $showingAdd) { AddWineView(startOnWishlist: showWishlist) }
            .sheet(isPresented: $showingSettings) { NamesView() }
        }
    }

    private func delete(at offsets: IndexSet) {
        let items = filtered
        for index in offsets { context.delete(items[index]) }
    }
}

struct WineRow: View {
    let wine: Wine

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: wine.style.symbol)
                .foregroundStyle(Theme.burgundy)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(wine.displayName).font(.headline)
                if !wine.subtitle.isEmpty {
                    Text(wine.subtitle).font(.subheadline).foregroundStyle(.secondary)
                }
                HStack(spacing: 8) {
                    if !wine.isWishlist { StarsDisplay(rating: wine.rating) }
                    if !wine.taster.isEmpty {
                        Text(wine.taster).font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }
}
